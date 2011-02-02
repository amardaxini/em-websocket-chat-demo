require 'rubygems'
require 'eventmachine'
require 'em-websocket'
require 'ruby-debug'
require 'json'
#DB_ENV = 'development'
#ActiveRecord::Base.establish_connection(YAML.load_file("em_db.yml")[DB_ENV])
#class User < ActiveRecord::Base
#  scope :active, where("current_sign_in_at >= ? ",340.minutes.ago) #(added 5.30 hr+10 minutes ago need to check)
#  #named_scope
#
#end
#module EventMachine
module Chat
	def init

	end
# create instance variable for 2 user set channel and queue
# param1= 2,param=1
# instance variable is @channel_1_2 = {"channel"=>Em::Channel.new,"queue"=>EM::Queue.new}
	def create_channel(param1,param2)
		param1,param2=arrange_caller_and_calee(param1,param2)
		if instance_variable_get("@channel_#{param1}_#{param2}").nil?
			instance_variable_set("@channel_#{param1}_#{param2}", {"channel"=>EM::Channel.new,"queue"=>EM::Queue.new})
		end
	end
# get instance variable
# param=2,param=1
# it will return nil if @channel_1_2 is not present otherwise it return instance variable	
	def get_channel(param1,param2,ws)
		param1,param2=arrange_caller_and_calee(param1,param2)
		if instance_variable_get("@channel_#{param1}_#{param2}").nil?
			#set_channel(param1,param2,ws)
			return nil
		end
		instance_variable_get("@channel_#{param1}_#{param2}")
	end
#get instance variable and Subscribing channel

	def subscribe_channel(param1,param2,ws)
		get_channel(param1,param2,ws)["channel"].subscribe{ |msg| ws.send msg}
	end
# create instance variable
#	subscribe channel
# return instance variable	
	def set_channel(user_one_id,user_two_id,ws)
		if user_one_id !=user_two_id
			caller_id,calee_id = arrange_caller_and_calee(user_one_id,user_two_id)
			create_channel(caller_id,calee_id)
			subscribe_channel(caller_id,calee_id,ws)
			get_channel(caller_id,calee_id ,ws)
		end
	end
# set individual user channel	
	def set_user_channel(user_one_id,ws)
		create_user_channel(user_one_id)
		subscribe_user_channel(user_one_id,ws)
		get_user_channel(user_one_id,ws)
	end
# create individual channel
	def create_user_channel(param1)
		if instance_variable_get("@channel_#{param1}").nil?
			instance_variable_set("@channel_#{param1}",{"channel"=> EM::Channel.new,"queue"=>EM::Queue.new})
		end
	end
# return individual channel
	def get_user_channel(param1,ws)
		if instance_variable_get("@channel_#{param1}").nil?
			puts "Please Ensure Channel Is Present"
			# set_user_channel(param1,ws)
			return nil
		end
		instance_variable_get("@channel_#{param1}")
	end
# subscribe individual user channel
	def subscribe_user_channel(param1,ws)
		get_user_channel(param1,ws)["channel"].subscribe{ |msg| ws.send msg}
	end
	#swap caller,calee
	def arrange_caller_and_calee(param1,param2)
		if param1 !=param2
			if  param1 > param2
				caller_id,calee_id = param2,param1
			else
				caller_id,calee_id =  param1,param2
			end
		end
		[caller_id,calee_id]

	end
end

include Chat

@channels = {}
@individual_channels = {}
#  @users = {}
#
EventMachine::WebSocket.start(:host => 'localhost', :port => 8080) do |ws|
	ws.onopen {}
	#Socket receives json message parse it
	ws.onmessage { |msg|
		json_msg = JSON.parse(msg)
		#puts json_msg
		# if json_msg is login then there are 2 cases

		if json_msg["message"] == "login"

			if !json_msg['to'].empty?
				# It create channel between 2 users 
				@channels[ws.object_id]=set_channel(json_msg['from'],json_msg['to'],ws)
			else
				# for session handling
				# this is used for mainly notification here individual channel id created
				@individual_channels[ws.object_id]=set_user_channel(json_msg['from'],ws)
			end
		elsif json_msg['message'] == "message"
			# when message type is message then if channel is created and both user is active
			# then uid is 2 then send message
			if !get_channel(json_msg['from'],json_msg['to'],ws).nil? && !get_channel(json_msg['from'],json_msg['to'],ws)["channel"].nil?
				uid = get_channel(json_msg['from'],json_msg['to'],ws)["channel"].send(:instance_variable_get,:@uid)
				if uid >= 2
					if get_channel(json_msg['from'],json_msg['to'],ws)["queue"].size > 0
						get_channel(json_msg['from'],json_msg['to'],ws)["queue"].size.times do
							get_channel(json_msg['from'],json_msg['to'],ws)["queue"].pop do |msg|
								get_channel(json_msg['from'],json_msg['to'],ws)["channel"].push({"from_name" => msg['from_name'],"content" => msg['content']}.to_json)
							end
						end
					end
					get_channel(json_msg['from'],json_msg['to'],ws)["channel"].push({"from_name" => json_msg['from_name'],"content" => json_msg['content']}.to_json)
				else
					# if uid is less than 2 i.e 1

					if !get_user_channel(json_msg['to'],ws).nil? && !get_user_channel(json_msg['to'],ws)["channel"].nil?
						#debugger
						uid = get_user_channel(json_msg['to'],ws)["channel"].send(:instance_variable_get,:@uid)
					# then if individual channel is present and uid is 1 then notify him that some user wants to chat with you
						if uid>=1
							if get_channel(json_msg['from'],json_msg['to'],ws)["queue"].size <= 10
								get_channel(json_msg['from'],json_msg['to'],ws)["queue"].push(json_msg)
							end
							get_user_channel(json_msg['to'],ws)["channel"].push({"from_name" => json_msg['from_name'],"content" => "#{json_msg['from_name']} wants to chat",:message=>"notify"}.to_json)
							get_user_channel(json_msg['from'],ws)["channel"].push({"from_name" => json_msg['from_name'],"content" => "#{json_msg['to_name']} send notification for chat wait for acceptance",:message=>"notify"}.to_json)
						else
							#if channel is present and uid is 0 then he is not login or logout
							get_user_channel(json_msg['from'],ws)["channel"].push({"from_name" => json_msg['from_name'],"content" => "#{json_msg['to_name']}: is not active user will not receive your chat",:message=>"notify"}.to_json)
						end
					else
						# if individual channel is not present then notify him user is not active 
						get_user_channel(json_msg['from'],ws)["channel"].push({"from_name" => json_msg['from_name'],"content" => "#{json_msg['to_name']}: is not active user will not receive your chat",:message=>"notify"}.to_json)
						#or ws.send can be used
					end
				end
			end
		end
	}

	ws.onclose   {

		channel = @channels[ws.object_id]
		#IF channel is of communication and one guy is left
		#then unsubscribe from this channel delete from communication channel 	
		if !channel.nil?
			channel["channel"].unsubscribe(ws)
			# HACK In Event Machine
			# If user is not connected then refresh or connection close then  uid-1
			# It is helpful for notification
			uid = channel["channel"].send(:instance_variable_get,:@uid)-1
			channel["channel"].send(:instance_variable_set,:@uid,uid) #if uid!=0
			#Hack In uid
			@channels.delete(ws.object_id)
		else
			# if it is individual channel
			# then unsubscribe from this channel and remove from individual channels
			# this require to identify user is active or not
			channel = @individual_channels[ws.object_id]
			if !channel.nil?
				channel["channel"].unsubscribe(ws)
				uid = channel["channel"].send(:instance_variable_get,:@uid)-1
				channel["channel"].send(:instance_variable_set,:@uid,uid) #if uid!=0
				@individual_channels.delete(ws.object_id)
			end
		end
		ws.send "WebSocket closed"
	}
end

