
var chatboxmanager = function() {
    var boxList = new Array();
    // list of boxes shown on the page
    var showList = new Array();
    var config = {
        width : 250,
        gap : 20
    };

    var init = function() {
        $.extend(config)
    };

    var getNextOffset = function() {
        return (config.width + config.gap) * showList.length;
    };

    var boxClosedCallback = function(id) {
        // close button in the titlebar is clicked
        var idx = showList.indexOf(id);

        if(idx != -1) {
            showList.splice(idx, 1);
            var diff = config.width + config.gap;
            for(var i = idx; i < showList.length; i++) {
                var offset = $("#" + showList[i]).chatbox("option", "offset");
                $("#" + showList[i]).chatbox("option", "offset", offset - diff);
            }
        }
        else {
            alert("should not happen: " + id);
        }
    };

    var addBox = function(id,fname,name,websocket) {

        var idx1 = showList.indexOf(id);
        var idx2 = boxList.indexOf(id);
        // alert(idx2);
        if(idx1 != -1) {
            // found one in show box, do nothing
        }
        else if(idx2 != -1) {
            // exists, but hidden
            // show it and put it back to showList
            $("#"+id).chatbox("option", "offset", getNextOffset());
            var manager = $("#"+id).chatbox("option", "boxManager");
            manager.toggleBox();
            showList.push(id);
        }
        else {

            var el = $("#"+id);
            //  alert(el);

            // alert(fname);
            $(el).chatbox({id : id,
                user : fname,
                title : fname,
                hidden : false,
                width : config.width,
                offset : getNextOffset(),
                messageSent : function(id, user, msg) {
                    websocket.sendmsg(websocket,msg);
                },
                boxClosed : boxClosedCallback
            });
            boxList.push(id);
            showList.push(id);
        }
    };

    return {
        init : init,
        getNextOffset : getNextOffset,
        addBox : addBox

    }
}();





//function EmWebSocket(id,from,from_name,to,to_name)
//{
//    this.logpanel = $("#"+id);
//    this.em_to =to ;
//    this.em_from = from;
//    this.from_name = from_name;
//    this.to_name = to_name;
//    this.common_json = {"from":from,"to":to,"from_name":from_name,"to_name":to_name};
//    conne = this.connect(this);
//}
//
//EmWebSocket.fn = EmWebSocket.prototype;
//
//function logg(em,data){
//
//    if(data['from_name'] ==  undefined)
//    {
//        message = data;
//        notify = ""
//    }
//    else {
//
//        message = data['from_name']+":"+data['content'];
//        if(data['message'] == 'notify')
//            notify = data['message'];
//    }
//
//    $("#logp").append("<p>"+message+"</p>");
//    if(notify!="")
//    {
//        $("#polling").html(message);
//    }
//    em.logpanel.append(message);
//    //scrollToBottom();
//};
//
//EmWebSocket.fn.scrollToBottom=function() {
//    window.scrollBy(0, document.body.scrollHeight - document.body.scrollTop);
//};
//EmWebSocket.fn.connect = function(obj){
//    var conn;
//    if (window["WebSocket"]) {
//        conn = new WebSocket("ws://localhost:8080" );
//        conn.onmessage = function(evt) {
//            logg(obj,JSON.parse(evt.data));
//        };
//        conn.onclose = function() {
//
//            logg(obj,"** you have been disconnected");
//            obj.common_json['message'] = "close";
//            conn.send(JSON.stringify(obj.common_json));
//        };
//        conn.onopen = function(){
//            logg(obj,"** you have been connected");
//
//            obj.common_json['message'] = "login";
//
//            conn.send(JSON.stringify(obj.common_json));
//        }
//    }
//    return conn;
//};
//
//EmWebSocket.fn.sendmsg = function(obj,msg){
//
//    if(conne && conne.readyState == 1){
//        //   history.unshift(msg);
//        obj.common_json['message'] = "message";
//        obj.common_json['content'] = msg;
//        conne.send(JSON.stringify(obj.common_json));
//        idx = 0;
//
//    }
//};
  

