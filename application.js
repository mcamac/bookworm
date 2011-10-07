
	var searchBoxes;

	var options=['Term(s)', 'Subject(s)']; //'Publication Country', 'Publisher', 'Date Written'];
	var placeholders=['she, her, hers', 'E', 'eng', 'blah', '1850'];
	var categories;
			var headings;
			var bookLinks;
	for(var i=0;i<=options.length;i++){
		placeholders[options[i]]=placeholders[i];
	}
	$(document).ready(function(){
		$('.medialcheck').hide();
		$.getJSON('static/json/cats.json',function(json){
			categories = {};
			headings = [];
			for(var key in json){
				if(key.length ==1) {categories[key]=json[key];headings.push(key);}
			}
			headings = headings.sort();
			$('#category-browser p').append(' <select class=catselect id=catselect multiple="multiple" size=10> </select>');
			for(var i=0;i<headings.length;i++){
			var key = headings[i];
			$('#category-browser select').append('<option value='+key+'>'+key+': '+categories[key]+'</option>');
			}
		})

		$('body').append('<img id="feedback" src="static/images/feedback1.png" alt="feedback" width="100" height="30" />');
		$('#feedback').feedback(); //use your chosen selector. I am using an image with an id of 'feedback'
		$('#feedback').colorbox({width:"50%", inline: true, href: "#fback"});
		console.log('DOM ready');
		searchBoxes=0;
		addSearchBox();
		$('#ngrams').val('Boston');

		//years text updating
		$('#years').change(function(){
			return false;
			var sp = $(this).val().split(' - ');
			$('#year-slider').slider({
				values: [sp[0], sp[1]]
			});
			submitForm();
		});
		///for testing, make chart initially
		//makeChart();
		$('#queries select.condition').live('change', function(){fixOptions();
				if($(this).val()=='Subject(s)'){
				$('td.tdinput',$(this).parents('tr')).html($('#catselect').clone(false).attr('id',''));
				$('.catselect',$(this).parents('tr')).multiselect({
					noneSelectedText: "Choose subjects"	
				});
			}
			else if($(this).val()=='Term(s)') $('td.tdinput',$(this).parents('tr')).html('<input class=option type=text placeholder=Boston>');
			else $('td.tdinput',$(this).parents('tr')).html('<input class=option1 type=text>');
		});
		$('.help').colorbox({href:"help.html", width:"70%", height: '70%'});

		//category selector popups
		//$('.cattext').live('create',function(){$.colorbox({width:"50%", inline: true, href:"#category-browser"});});
			
		//hitting 'enter' should submi
		$('#ngrams, input.option').live('keyup',function(e){
			if(e.keyCode==13) submitForm();
		});
		//year slider
		$('#year-slider').slider({
			range: true,
			min: 1700,
			max: 2000,
			values: [1830, 1922],
			slide: function( event, ui) {
				$('#years').val(ui.values[0] +" - " +ui.values[1]);
			},
			change: function(){
			if($('#year-slider').slider('values',0) >= 1820) $('.medialcheck').hide();
			else $('.medialcheck').show();	
			$('#years').val($('#year-slider').slider("values", 0) +" - " +$('#year-slider').slider("values", 1));
			submitForm()
			}
		});
		$('#years').val($('#year-slider').slider("values", 0) +" - " +$('#year-slider').slider("values", 1));
		//submit button
		$('#submit-query').click(submitForm);
		//view query button
		$('#seequery').click(function(){$('#querycode').html(buildQuery()); $.colorbox({width:"50%", inline: true, href:'#querycode'});});
		
		//year options change
		$('#yeartype').change(fixYears);
		
		submitForm();
	});
	
	//fix years text/slider on update
	function fixYears(){
		var yeartype = $("#yeartype").val();
		if(yeartype=='year'){
			$('#year-slider').slider({
			range: true,
			min: 1700,
			max: 2000,
			values: [1830, 1922],
		});
		}else if(yeartype=='author_age'){
			$('#year-slider').slider({
			range: true,
			min: 18,
			max: 100,
			values: [30, 75],
		});
		}else if(yeartype=='authorbirth'){
			$('#year-slider').slider({
			range: true,
			min: 1564,
			max: 1950,
			values: [1780, 1880],
		});
		}

		$('#years').val($('#year-slider').slider("values", 0) +" - " +$('#year-slider').slider("values", 1));
		
	}
	function validateQuery(){
		var error='';
		if($('#ngrams').val()=='') error='No term(s) specified.'; 
		$('input.option').each(function(i,el){
			if($(el).val()=='') error='Missing term(s).';
		});
		//check if more than 2 of 2 options
			var counts = {};
			$(options).each(function(index, elt){
				counts[elt]=0;
			});
			counts['Term(s)']=1;
			$('#queries select.condition option:selected').each(function(index, elt){
				val = $(elt).attr('value');
				counts[val]++;
			});
		var n=0;
		for(var key in counts){
			if (counts[key]>=2) n++;
		}	
		if(n>=2) error='Must only have one option with more than two fields.';
		console.log(counts);
		if(error!=''){
			$('#errors p').html(error);
			return false;
		}
		$('#errors p').html('');
		return true;
	}

	function submitForm(){
		if(!validateQuery()) return false;
		var query = buildQuery();
		$.ajax({
			url: '/cgi-bin/corebindings.py',
			type: 'post',
			data: 'method=plot&queryTerms='+query,
			dataType: 'html',
			success: function(response){
			var dataSplit = response.split('html');
			//console.log(response);
			var dataEval = JSON.parse(dataSplit[1]);

			makeChart(dataEval);
				$('#querycode').html(query);
			}

		});
				makeChart(query);
		//return true;
	}
function makeChart(data){
    console.log(data);
    var n = data['series'].length;
    var serie = [];
    for(var s=0;s<n;s++){
	var test = data.series[s]['values'];
	var a = [];
	var series={};
	for(var i=$('#year-slider').slider('values',0);i<=$('#year-slider').slider('values',1);i++){
	    if((i) in test){
		var ss = data.series[s]['search_strings'];
		ss['year']=i;
		a.push({x:i, y: parseFloat(test[i+'']), qString:JSON.stringify(ss)});
	    }
	}
	series['name']=data.series[s]['Name'];
	series['options']={};
	series['options']['test']='blah';
	series['data']=a;
	serie.push(series);
    }
    
    var xAxisLabel =  data['options']['xlab'];
    var yAxisLabel =   data['options']['ylab'];
    
    
    var chart1 = new Highcharts.Chart({
	    chart : {renderTo: 'chart', type: 'line'},
	    title: {text: null},
	    xAxis: {title: { text: xAxisLabel},
		    labels: { formatter: function() {return this.value;}},
		    min: $('#year-slider').slider('values',0),
		    max: $('#year-slider').slider('values',1)
	    },
	    yAxis: {title: { text: yAxisLabel},
		    min: 0
	    },
	    legend: {layout: 'vertical', align: 'top', verticalAlign: 'top', floating: true},
	    series: serie,
	    plotOptions: {line: {animation: false},
			  series: {marker: {radius: 1},
				   cursor: 'pointer',
				   events: {
			click: function(event) {
			    var name = this.name;
			    var qq = JSON.parse(event.point.qString);
			    var titleString = 'Books for series "'+name+'" in '+qq['year'];
			    $('#bookdivtitle').html(titleString);
			    $.ajax({
				    url: '/cgi-bin/corebindings.py',
					type: 'post',
					data: 'method=books&queryTerms='+event.point.qString,
					success: function(response){
					response = response.split('html')[1];
					//$('#books').html(response);
					var dataArray = eval(response);
					console.log(response);
					bookLinks=[];
					for(var i=0;i<dataArray.length;i++){
					    var linkData = dataArray[i];
					    var cat_link = '<a class=booklink href="'+linkData['cat_url']+'"target="_blank">More info</a>';
					    var read_link = '<a class=booklink href="'+linkData['read_url']+'"target="_blank">Read</a>';
					    var row = "<tr><td><img src='" + linkData['cover-image'] + "'width=44 height=58 /></td><td><span class=booktitle>"+linkData['title']+"</span> <span class=bookauthor> by "+linkData['author']+"</span> "+cat_link+" "+read_link+"</td></tr>";
					    bookLinks.push(row);
					    //console.log(row);
					}
					$('#pagination').pagination(dataArray.length, {items_per_page: 10, callback: handlePaginationClick});
					$('#bookdiv').html('<table></table');
					for(var i=0;i<Math.min(6,dataArray.length);i++) {
					    console.log(bookLinks[i]);
					    $('#bookdiv table').append(bookLinks[i]);
					}
					console.log(bookLinks[i]);
					$.colorbox({width:'75%', inline: true, href:'#books'});
				    }
				});
			    
			}
		    }
			  },
			  
	    }
	});
}
function handlePaginationClick(new_page_id, pagination_container) {
		// This selects 20 elements from a content array
		$('#bookdiv').html('<table></table');
		for(var i=new_page_id*10;i<(new_page_id+1)*10;i++) {
			console.log(bookLinks[i]);
			$('#bookdiv table').append(bookLinks[i]);
		}

		return false;
	}
	function buildQuery(){
		var query={};
		query["time_measure"]=$('#yeartype').val();
		
		query["time_limits"] = [$('#year-slider').slider("values",0),$('#year-slider').slider("values", 1)];

		query["countfunction"] = 'sum';
		query['words_collation'] = 'case insensitive';
		query['medial-s-correction'] = $('#medialcheck').is(':checked');
		query['counttype']= $('#collationtype').val();
		query['search_limits'] = {};
		query['search_limits']['subset'] = ['test'];
		
		var firstTerm = termArray($('#ngrams').val());
		var params = $.map($('#queries select.condition'),function(el){return $(el).val();});
		var counts = {};
			$(options).each(function(index, elt){
				counts[elt]=0;
			});
			counts['Term(s)']=1;
			$('#queries select.condition option:selected').each(function(index, elt){
				val = $(elt).attr('value');
				counts[val]++;
			});
		console.log(counts);
		if(counts['Subject(s)']>=2){
			query['search_limits']['word'] = firstTerm;
			query['split_element'] = 'lc0';

			query['search_limits']['other_splits'] =[]; //[['cat','cats']];
			$('#queries select.condition option:selected').filter('[value="Subject(s)"]').each(function(i,el){
				if(i==0) query['search_limits']['lc0']=$('select.catselect', $(el).parents('tr')).val();
				else query['search_limits']['other_splits'].push($('select.catselect', $(el).parents('tr')).val());
			});
		}else{
			query['split_element'] = 'word';
			query['search_limits']['word'] = firstTerm;
			console.log('hereio');
			$('#queries select.condition').each(function(i, el){
				if($(el).val()!='Term(s)')
					query['search_limits']['lc0']=$('select.catselect', $(el).parents('tr')).val();
			});
			query['search_limits']['other_splits'] =[]; //[['cat','cats']];
			$('#queries select.condition option:selected').filter(function(i){return ($(this).val()=='Term(s)');}).each(function(i,el){
				query['search_limits']['other_splits'].push(termArray($('input',$(el).parents('tr')).val()));
			});
			//query['search_limits']['lc1'] = ['PZ'];
		}
		
		return JSON.stringify(query);
	}

	function termArray(str){ return $.map(str.split(','),function(v,i){return $.trim(v);});}
	function fixOptions(){
		console.log("\nfixing options");
		$('#queries select.condition option').removeAttr('disabled');
			var counts = [];
			$(options).each(function(index, elt){
				counts[elt]=0;
			});
			counts['Term(s)']=1;
			$('#queries select.condition option:selected').each(function(index, elt){
				val = $(elt).attr('value');
				counts[val]++;
			});

			$(options).each(function(i,o){
				if(counts[o]>=2){
					if(o!='Term(s)'){
						$('#queries select.condition option').filter('[value="Term(s)"]').each(function(i,elt){
							if($('option:selected',$(this).parent('select')).val()!=o)
								$(elt).attr('disabled','disabled');
						});
					}
					$('#queries select.condition osption:selected').each(function(i, elt){
						if($(elt).val()!=o && $('#queries select.condition option:selected').filter('[value="'+$(elt).val()+'"]').length ==1){
							$('#queries select.condition option:selected').each(function(j,e2){
								if($(e2).val()!=o && $(e2).val()!=$(elt).val())
									$('option',$(e2).parent('select')).filter('[value="'+$(elt).val()+'"]').attr('disabled','disabled');
								if($(e2).val()==o)
									$('option',$(e2).parent('select')).filter('[value="'+$(elt).val()+'"]').attr('disabled','disabled');
							});
						}
					});
					return false;
				}
			});
		
	}
	function optionString(options){
		return	'<option>Select constraint...</option>'+$.map(options, function(v,i){return '<option>'+v+'</option>';}).join('');
	}

	function addSearchBox(){
		n=searchBoxes;
		$('#queries tr.top').append('<div class=searchbox id=searchdiv'+n+'><table><tr class=fixedrow><td class=searchlabel><label for=ngrams>Term(s)</label></td><td class=tdinput><input type=text id=ngrams placeholder=Boston></td></div></table><table><div> <tr><td><a href = "#" class = toggleoptions>Filter or compare by catalog information</a></tr></td></table></div>');
		$('#queries').append('<div class=optiondiv><table></table></div>');
		$('#queries div.optiondiv table').append('<tr class=plusrow><td><input type=image width=16 height=16 src="static/images/plus.png" class=searchplus id=searchplus'+n+'></td></tr>');
		addOption('#searchdiv'+n);
		//$('tr.optionrow').toggle();
		$('#queries div.optiondiv').hide();
		$('a.toggleoptions').click(toggleOptions);
		$('input.searchplus').live('click',function(){
			addOption('#'+$(this).parents('div .searchbox').attr('id'));
		});
		$('input.searchminus').live('click',function(){
			$(this).parents('tr.optionrow').remove();
			fixOptions();
		});
		searchBoxes++;
	}
	function addOption(elt){
		$('#queries div.optiondiv tr.plusrow').before('<tr class=optionrow><td class=searchlabel><select class=condition>'+optionString(options)+'</select></td><td class=tdinput><input type=text id=ngrams placeholder=All class=option1></td><td><input type=image width=16 src="static/images/minus.png" class=searchminus></td>	</tr>');
	fixOptions();		
	}
	function toggleOptions(){
			if($('#queries div.optiondiv').is(":visible")){
			$('#queries div.optiondiv').slideUp(200);
			$('a.toggleoptions').html('Show catalog limits');
			}else{
			$('#queries div.optiondiv').slideDown(200);
			$('a.toggleoptions').html('Hide Catalog limits');
			}
		}

