// Step 1 - Include all the required JS & CSS files
var jqueryref=document.createElement('script');																					//jquery
jqueryref.setAttribute("src", "//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js")
document.getElementsByTagName("head")[0].appendChild(jqueryref);

var jqueryUIref=document.createElement('script');
jqueryUIref.setAttribute("src", "//ajax.googleapis.com/ajax/libs/jqueryui/1.11.1/jquery-ui.min.js");
document.getElementsByTagName("head")[0].appendChild(jqueryUIref);

var jqueryUICSSref=document.createElement("link");
jqueryUICSSref.setAttribute("rel", "stylesheet");
jqueryUICSSref.setAttribute("type", "text/css");
jqueryUICSSref.setAttribute("href", "//ajax.googleapis.com/ajax/libs/jqueryui/1.11.1/themes/smoothness/jquery-ui.min.css");
document.getElementsByTagName("head")[0].appendChild(jqueryUICSSref);

var connectionjs=document.createElement('script');
connectionjs.setAttribute("src", "/soap/ajax/15.0/connection.js")
document.getElementsByTagName("head")[0].appendChild(connectionjs);

var apexjs=document.createElement('script');
apexjs.setAttribute("src", "/soap/ajax/15.0/apex.js")
document.getElementsByTagName("head")[0].appendChild(apexjs);

// Finally, once the last javascript library is loaded, callback to success
connectionjs.onload = success;
apexjs.onload = success;
jqueryref.onload = success;


function parseWorks(jsonString)
{
	try
	{
		$j.parseJSON(jsonString);
		return true;
	}
	catch(x)
	{
		return false;
	}
}


function success()
{
	if(typeof sforce == 'undefined' || typeof sforce.apex == 'undefined' || typeof jQuery == 'undefined')
		return;
	$j = jQuery.noConflict();
    $j("#AppBodyHeader").append("<div id='tifyMe'><span id='masterText'></span></div>");
    alert(typeof $j("#tifyMe").dialog);

	var myCookie = document.cookie.replace(/(?:(?:^|.*;\s*)sid\s*\=\s*([^;]*).*$)|^.*$/, '$1');
	sforce.connection.sessionId = myCookie;
	var jsonString = sforce.apex.execute('notifyClass', 'getMessageToShow', {});
	if(jsonString == '' || jsonString == null)
	{
		return;
	}

	var notifObject;
	if(parseWorks(jsonString))
	{
		notifObject = $j.parseJSON(jsonString);
	}
	else
	{
		notifObject = (new Function('return ' + jsonString))();
	}

	var theId = notifObject.Id;
	var theText = notifObject.Message;
	var theTheme = notifObject.Theme;
	var theWidth = notifObject.Width;
	if(theTheme != '')
	{
		$j("link[href*='jquery-ui.min.css']").remove();
		var themeCSS = $j("<link rel='stylesheet' type='text/css' href='//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/themes/" + theTheme + "/jquery-ui.min.css />");
		$j('head').append(themeCSS);
	}

	$j('#masterText').html(theText);

	$j("#tifyMe").dialog
   (
        {
            modal: true
            ,width: theWidth
            ,title: "Notification"
            ,show: 
            {
                effect: 'fadeIn'
                ,duration: 350
                ,times : 3
            }
            ,hide: 
            {
                effect:'fadeOut'
                ,duration: 350
                ,times: 3 
            }
            ,buttons: 
            {
                Ok: function()                     
                {                       
                    $j( this ).dialog('close');
                }
                ,close: function()
                {
                    sforce.apex.execute('notifyClass','acknowledgeWithId', {notifId: theId});
                }
            }
        }
    );
}