<cfset Variables.aProjects			= ArrayNew(1)>
<cfset Variables.inprogress 		= ArrayNew(1)>
<cfset Variables.hibernating 		= ArrayNew(1)>
<cfset Variables.finished 			= ArrayNew(1)>
<cfset Variables.finishednophoto 	= ArrayNew(1)>
<cfset Variables.todolist 			= "inprogress,finishednophoto,hibernating">
<cfset Variables.counter 			= 1>
<cfset Variables.ravname			= "caracolina">
<cfset Variables.key				= "ec9ae57dd9516720c35c3df8d8094940a20ee480">

<!--- grab project data --->
<cfhttp url="http://api.ravelry.com/projects/#Variables.ravname#/progress.json?key=#Variables.key#&status=in-progress+hibernating+finished&notes=true">

<!--- parse JSON array into Coldfusion array --->
<cfif !IsJSON(cfhttp.filecontent.toString())>
	Something went wrong!
	<cfabort>
<cfelse>
	<cfset aProjects = DeSerializeJSON(cfhttp.filecontent.toString())>
</cfif>

<!--- loop over projects array --->
<cfloop from="1" to="#ArrayLen(aProjects.projects)#" index="project">
	<!--- sort projects into separate arrays for each status --->
	<cfset ArrayAppend(Variables["#Replace(aProjects.projects[project].status,'-','')#"], aProjects.projects[project])>
	<!--- add finished projects without photo into their own array ---> 
	<cfif aProjects.projects[project].status eq "finished" and not isStruct(aProjects.projects[project].thumbnail)>
		<cfset ArrayAppend(Variables.finishednophoto, aProjects.projects[project])>
	</cfif> 
</cfloop> 

<!--- page content start - normally I would not have the above on the same template as the content --->

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
<script type="text/javascript" language="javascript" src="carouFredSel-5.6.2/jquery.carouFredSel-5.6.2.js"></script>
<script type="text/javascript" language="javascript" src="carouFredSel-5.6.2/jquery.touchSwipe.js"></script>
<link href="stylesheets/ravelry_global_1207201616.css" rel="Stylesheet" type="text/css" />
</head>
<body class="notebook" style="margin-left: 50px; margin-top: 50px">
<div id="projects_panel" style="position: relative" class="projects_index_panel panel" style="height: auto;">
<cfoutput>
	
<h1>My Ravelry To-Do List:</h1>
	
<div id="projects_results">

<cfif not (ArrayLen(Variables.inprogress) and ArrayLen(Variables.finishednophoto) and ArrayLen(Variables.hibernating))>
	You have no open, photo-less, or hibernating projects to update!

<cfelse>	
	<cfloop list="inprogress,finishednophoto,hibernating" index="todo">
	<cfset Variables.arrayTodo = Variables[todo]>
	<cfif ArrayLen(Variables.arrayTodo)>		
			<div style="clear:both;" class="c_d"></div>		
			<div id="#todo#_projects" class="thumbnails">		
			<h2 style="margin-top: 30px">#Variables.counter#. 
			<cfif todo eq "inprogress">
				Update WIPS: 
			<cfelseif todo eq "finishednophoto">
				Add Photos to FOs:
			<cfelseif todo eq "hibernating">
				Un-Hibernate:
			</cfif>
			</h2>
			<cfloop from="1" to="#ArrayLen(Variables.arrayTodo)#" index="project">
			<div class="thumbnail" id="thumbnail_#project#">
			<div class="title"><a href="#Variables.arrayTodo[project].url#" target="rav">#Variables.arrayTodo[project].name#</a></div>
				<div class="photo_border framed_photo">
					<div class="photo_frame">
						<a class="photo" href="#Variables.arrayTodo[project].url#" target="rav"
							id="#Variables.arrayTodo[project].permalink#" 
							<cfif IsStruct(Variables.arrayTodo[project].thumbnail)>
							style="background-image: url('#Variables.arrayTodo[project].thumbnail.medium#'); background-size: contain; background-position: -12px 7px; background-repeat: no-repeat;"
							</cfif>>
							<cfif not IsStruct(Variables.arrayTodo[project].thumbnail)>
								no thumbnail photo
							</cfif></a>
					</div>
				</div> 
			</div>
			</cfloop>
			</div>				
			<cfset Variables.counter = Variables.counter + 1>
		</cfif>
	</cfloop>	
	</div>
	<div style="clear:both;" class="c_d"></div>
</cfif> 

<!--- played around with a jquery gallery plugin --->
<style type="text/css" media="all">
	.list_carousel { 
				background-color: ##fff;
				margin: 0 0 30px 20px;
			}
</style>

<script type="text/javascript" language="javascript">
$(function() {
	$('##foo0').carouFredSel({
			align: 'left',
			//responsive  : true,
			scroll      : 1,
			items       : 5,
			auto: {
				pauseOnHover: 'resume',
				onPauseStart: function( percentage, duration ) {
					$(this).trigger( 'configuration', ['width', function( value ) { 
						$('##timer1').stop().animate({
							width: value
						}, {
							duration: duration,
							easing: 'linear'
						});
					}]);
				},
				onPauseEnd: function( percentage, duration ) {
					$('##timer1').stop().width( 0 );
				},
				onPausePause: function( percentage, duration ) {
					$('##timer1').stop();
				}
			}
					
		});

});
</script>

<h1 style="margin-top: 30px">Finished Objects</h1>
<cfif ArrayLen(Variables.finished)>
	<div class="list_carousel " id="foo0">
	<cfloop from="1" to="#ArrayLen(Variables.finished)#" index="project">
		<cfif IsStruct(Variables.finished[project].thumbnail)>
		<div class="thumbnail" id="thumbnail_#project#">
			<div class="photo_border framed_photo">
					<div class="photo_frame">
						<a class="photo" href="#Variables.finished[project].url#" target="rav"
							id="#Variables.finished[project].permalink#" 							
							style="background-image: url('#Variables.finished[project].thumbnail.medium#'); 
								background-size:contain ; background-position: -12px 7px; background-repeat: no-repeat;
								line-height: 270px" >
							#Variables.finished[project].name#</a>
					</div>
			</div> 
		</div>
		</cfif>
	</cfloop>
	</div>
<cfelse>
	<div>You have no finished objects</div>
</cfif>
</cfoutput>
</div>
</body>
</html>