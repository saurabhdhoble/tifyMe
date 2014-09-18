<script src="/soap/ajax/15.0/connection.js" type="text/javascript"></script>
<script src="/soap/ajax/15.0/apex.js" type="text/javascript"></script>
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"></script>
<link rel="stylesheet" type="text/css" href="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/themes/ui-lightness/jquery-ui.min.css">
<script>
	function parseWorks(jsonString)  
	{
		try
		{
			jQuery.parseJSON(jsonString);
			return true;    
		}
		catch(x)    
		{
			return false;    
		}  
	}  

	$(function()   
		{
			var myCookie = document.cookie.replace(/(?:(?:^|.*;\s*)sid\s*\=\s*([^;]*).*$)|^.*$/, "$1");
			sforce.connection.sessionId = myCookie;    
			$('h2:contains("tifyMe")').parent().parent().hide();    
			var jsonString = sforce.apex.execute("tifyMe.notifyClass", "getMessageToShow", {});    
			if(jsonString == "" || jsonString == null)    
			{
				return;    
			}

			var notifObject;
			if(parseWorks(jsonString))    
			{
				notifObject = jQuery.parseJSON(jsonString);   
			}
			else
			{
				notifObject = (new Function("return " + jsonString))();    
			}    

			/*var theText = sforce.apex.execute("tifyMe.notifyClass", "getMessageWithId", {notifId: theId});*/    
			/*var theTheme = sforce.apex.execute("tifyMe.notifyClass", "getMessageThemeWithId", {notifId: theId});*/    

			var theId = notifObject.Id;    
			var theText = notifObject.Message;    
			var theTheme = notifObject.Theme;    
			var theWidth = notifObject.Width;    

			if(theTheme != '')    
			{      
				$("link[href*='jquery-ui.min.css']").remove();
				var themeCSS = $('<link rel="stylesheet" type="text/css" href="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/themes/' + theTheme + '/jquery-ui.min.css" />');
				$("head").append(themeCSS);    
			}    

			$("#masterText").html(theText);    
			$( "#dialog-message" ).dialog(
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
					effect: "fadeOut"          
					,duration: 350          
					,times: 3        }        
					,buttons: { 
						Ok: function()
						{
							$( this ).dialog( "close" );
						}
					}
					,close: function()        
					{
						sforce.apex.execute("tifyMe.notifyClass", "acknowledgeWithId", {notifId: theId});
			        }      
			    }    
			);  
		});  
</script>

<div id="dialog-message" title="Basic dialog" style="display:none">	<span id="masterText"></span></div>