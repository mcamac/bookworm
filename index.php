<!DOCTYPE HTML>
<html lang="en">
<head>
	<script type="text/javascript" src="https://www.google.com/jsapi?key=ABQIAAAA7g_7_oWgWlujHkL8ql9TLxSEbjQlOMNZJgf9J6qwaQ4n7PCH_RTkMDD3NMKRTpU7n6jMa79BLeC1MA"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js"></script>
	<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/themes/base/jquery-ui.css" type="text/css" media="all" />
	<link href='http://fonts.googleapis.com/css?family=Droid+Sans:400,700' rel='stylesheet' type='text/css'>

	<script src="static/js/jquery.formalize.js" type="text/javascript"></script>
	<script src="static/js/jquery.feedback.js" type="text/javascript"></script>
	<script src="static/js/jquery.multiselect.min.js" type="text/javascript"></script>
	<script src="static/js/jquery.pagination.js" type="text/javascript"></script>
	<script src="static/js/highcharts.js" type="text/javascript"></script>
	<script src="static/js/urlEncode.js" type="text/javascript"></script>
	<script src="static/js/jquery.colorbox-min.js" type="text/javascript"></script>
	<script src="static/js/chosen/chosen.jquery.min.js" type="text/javascript"></script>
	<script src="static/js/coffee-script.js" type="text/javascript"></script>

	<link rel="stylesheet" href="static/css/formalize.css" />
	<link rel="stylesheet" href="static/css/colorbox.css" />
	<link rel="stylesheet" href="static/css/pagination.css" />
	<link rel="stylesheet" href="static/css/style.css" />
	<link rel="stylesheet" href="static/js/chosen/chosen.css" />
	<link rel="stylesheet" href="static/css/jquery.multiselect.css" />

	<meta charset="UTF-8">
	<title>bookworm</title>
	<script type=text/coffeescript src="static/coffee/application.coffee"></script>
	<script type="text/javascript">
	  
	  var _gaq = _gaq || [];
	  _gaq.push(['_setAccount', 'UA-4871207-7']);
	  _gaq.push(['_trackPageview']);
	  
	  (function() {
	  var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
	  ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
	  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
	  })();
	  
	</script>
</head>
<body>
	<h1> bookworm  <a href="#" class=about>[about]</a> <a href="#" class=help>[help]</a> </h1><hr />
	<div id=main>
	<div id=container>
	<div id=queries>
	<div id=big_div>
	<table>
	<tr>
	<td><span class=labeler>Compare the trajectory of: </span></td> </tr>
	<tr><td>
	<div class=big_select_div id=big_select>
	<select id=main_select>
	<option value=word>several words in the same collection of books</option>
	<option value=texts>the same word in several collections of books</option>
	</select>
	</div>
	</td> </tr>
	</table>
	</div>
	<hr />
	<p class=termlabel> Search for word(s): </p>
	<table class=terms>
	  <tr class='top'>
				<td class=ngrams><input class=ngrams placeholder="beta"></input></td><td class=color> </td>
				<td><a href="#" id='plus_word' class='plus_word' style="display:none">Add more words</a></td>
	  </tr>
	</table>
	<div id=comparison_div>
	<table>
	<tr><td><span class=labeler>...in the following (customizable) book <span id=define_label>collection</span>:</span></td></tr>
	</table>
	</div>
	<div id=cat_boxes>
	<table class=top>
	</table>
	</div>
	<a href=# id=plus style="display:none">Add another group of books</a>

	</div>
	<div id=errors>
	  <p> </p>
	</div>
	<hr />
	<div id=settings>
	  <table>
				    <tr><td><label for=yeartype>Time:</label></td>
	      <td>
		<select id=yeartype>
		</select>
	      </td> 
				
				
				</tr>
<tr><td></td><td width=175px><div id=year-slider></div> </td>
	      <td><input type=text id=years style="border: 0; width: 75px"></td></tr>

	    <tr><td>
		<label for=collationtype>Quantity:</label></td>
	      <td><select id=collationtype>
		  <option value='Occurrences_per_Million_Words'>per million words</option>
		  <option value='Percentage_of_Books'>% of books</option>
		  <option value='Raw_Counts'>Raw counts</option>
	      </select></td>
	    </tr>
		<tr><td>
		<label for=counttype>Collation:</label></td>
	      <td><select id=colltype>
		  <option value='Case_Sensitive'>Case Sensitive</option>
		  <option value='Case_Insensitive'>Case Insensitive</option>
		  <option value='All_Words_with_Same_Stem'>Same stem</option>
		  <option value='Correct_Medial_s'>Correct Medial s</option>
	      </select></td>

	    </tr>
		<tr><td><label for=smoothing>Smoothing:</label></td>
			<td>
			<select id=smoothing>
			</select>
			</td>
		</tr>
	  </table>
	</div>
	<div id = submitButtons>
	  <table>
	    <tr>  <td> <input type=submit id=submit-query></td> <td style="display: none;"><input type=submit id=seequery value="Permalink"></td></tr>
	  </table>
	</div>

	</div>
	<div id=chart_wrapper>
	<div id=chart>

	</div>
	<div id=chart_message>
	<table>
</table>
<table>
<tr>
<td>
	<div id="fb-root"></div>
	<script>(function(d, s, id) {
		  var js, fjs = d.getElementsByTagName(s)[0];
			if (d.getElementById(id)) {return;}
			js = d.createElement(s); js.id = id;
			js.src = "//connect.facebook.net/en_US/all.js#appId=267787889910866&xfbml=1";
			fjs.parentNode.insertBefore(js, fjs);
	}(document, 'script', 'facebook-jssdk'));</script>

	<div class="fb-like" data-href="bookworm.culturomics.org" data-send="true" data-layout="button_count" data-width="150" data-show-faces="true" data-font="lucida grande"></div>

	</td>

</tr><tr>
	<td>
	<!-- Place this tag where you want the +1 button to render -->
	<g:plusone size="small" width="150" annotation="inline" href="http://bookworm.culturomics.org"></g:plusone>

	<!-- Place this render call where appropriate -->
	<script type="text/javascript">
	  (function() {
			var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
			po.src = 'https://apis.google.com/js/plusone.js';
			var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
		})();
	</script>
	</td>

</tr>
<tr><td style="text-align: left;">
<a href="https://twitter.com/share" class="twitter-share-button" data-url="bookworm.culturomics.org" data-text="Bookworm" data-count="horizontal">Tweet</a><script type="text/javascript" src="//platform.twitter.com/widgets.js"></script>
</td></tr>
</table>
	</div>
	</div>
	<div style='display:none'>
		<div id=category-browser>
			<h1> Select subjects </h1><hr />
			<p> Category: </p>		
			
			</div>

	</div>
	</div>
	<div style='display:none'>
		<div id=querycode>
		</div>
	</div>
	<div style='display:none'>
		<div id=fback>
			<h1>Feedback</h1><hr />
			<p>Please contact martin at culturomics dot org with any questions/feedback. Thank you!</p> 
		</div>
	</div>
	<div style='display:none'>
		<div id=books>
		<div id=pagination></div>
		<br style="clear:both"/><hr />
		<div id=bookdivtitle></div>
		<div id=bookdiv>	
		</div>
		</div>
	</div>
	</div>
	<div id=footer>
	<hr />
	<p class=foot> Martin Camacho and Ben Schmidt, <a href="http://www.culturomics.org/cultural-observatory-at-harvard">Cultural Observatory</a>, 2011. <a href='mailto:ben@culturomics.org'>Contact</a>.<br />
Public domain texts and catalog information from the <a href=http://openlibrary.org>Open Library.</a><br />
	This is a proof-of-concept beta, submitted to the Digital Public Library of America Beta Sprint initiative. Data and interface may change at any time.

</p>

	</div>
	<span id=category_box_template class="box category_box_template"><table><tr class=category_box_row><td class=category_box_data><p class=box_data><span class=box_value>All metadata</span></a></td><td class=category_box_edit><a href=# class=box_edit>Edit</a></td><td class=category_box_x><a class=box_x href=#><span>x</span></a></td> </tr>
	</table></span>

</body>

</html>
