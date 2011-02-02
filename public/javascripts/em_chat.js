function EmWebSocket(id,from,from_name,to,to_name)
{
    this.logpanel = $("#"+id);
    this.em_to = to;
    this.em_from = from;
    this.from_name = from_name;
    this.to_name = to_name;
    this.common_json = {"from":from,"to":to,"from_name":from_name,"to_name":to_name};
    conn = this.connect(this);
}

EmWebSocket.fn = EmWebSocket.prototype;
function output(em,data){

    if(data['from_name'] ==  undefined)
    {
        message = data;
        notify = ""
    }
    else {
      //  alert(data['from_name']);
          message = data['from_name']+":"+data['content'];
      //  message = "<b>"+from_user+"</b>:"+data['content']+"\n";
        if(data['message'] == 'notify')
            notify = data['message'];
    }

    $("#logp").append("<p>"+message+"</p>");
    if(notify!="")
    {
        $("#polling").html(data['content']);
         $("#polling").css({"background-color":"aqua","margin":"10px","padding":'10px'});
    }
    em.logpanel.append("<p>"+message+"</p>");
    //scrollToBottom();
};
//function output(em,data){
//
//    if(data['from_name'] ==  undefined)
//    {
//        message = data;
//        notify = ""
//    }
//    else {
//        var from = '';
//
//         if ($(".profile").attr('user_id') == data['from_name']){
//          from = "me";
//          }
//         else {
//          from = data['from_name'];
//          }
//        message = "<b>"+from+"</b>:"+data['content']+"\n";
//        if(data['message'] == 'notify')
//          notify = data['message'];
//    }
//
//    if(notify!=""){
//        $("#polling").html(message);
//    }
//
//    em.logpanel.append("<p>"+message+"</p>");
//    //em.scrollToBottom();
//};

EmWebSocket.fn.scrollToBottom=function() {
    window.scrollBy(0, document.body.scrollHeight - document.body.scrollTop);
};

EmWebSocket.fn.connect = function(obj){
    var conn;
 
    // Everything below is the same as using standard WebSocket.
    if (window["WebSocket"]) {
        conn = new WebSocket("ws://localhost:8080/");

        conn.onmessage = function(evt) {
            output(obj,JSON.parse(evt.data));
            //  logg(obj,JSON.parse(evt.data));
            obj.scrollToBottom();
        };

        conn.onclose = function() {
            output(obj,"** you have been disconnected");
            //   logg(obj,"** you have been disconnected");
            obj.scrollToBottom();
            obj.common_json['message'] = "close";
            conn.send(JSON.stringify(obj.common_json));
        };

        conn.onopen = function(){
            output(obj,"** you have been connected");
            //   logg(obj,"** you have been connected");
            obj.scrollToBottom();
            obj.common_json['message'] = "login";
            conn.send(JSON.stringify(obj.common_json));
        }
    }
    else{
        alert("browser doesnot support web socket");
    }
    return conn;
};

EmWebSocket.fn.sendmsg = function(obj,msg){
    if(conn && conn.readyState == 1){
      
        obj.common_json['message'] = "message";
        obj.common_json['content'] = msg;
        conn.send(JSON.stringify(obj.common_json));
        idx = 0;
    }
};
