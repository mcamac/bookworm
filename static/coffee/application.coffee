$ -> (
	options = undefined
	terms = 'Word(s)'
	limits = []
	numCatBoxes = 0
	numWordBoxes = 1
	numSeries = 0
	colors = ['','128, 177, 211','251, 128, 114','179, 222, 105','141, 211, 199','190, 186, 218','252, 205, 229','217, 217, 217']
	hexColors = ['','#80B1D3','#FB8072','#B3DE69','#8DD3C7','#BEBADA','#FCCDE5','#D9D9D9']
	limit = 8
	data = []
	bookLinks=[]
	smooths = [0,1,2,3,4,5,6,7,8,9,10,20,30,40,50]
	for i in smooths
		$('#smoothing').append("<option>#{i}</option>")

	resizing = null
	$(window).resize(->
		clearTimeout(resizing)
		resizing = setTimeout(doneResizing,500)
		#$('#chart_wrapper').css('width',"#{$(document).width()-400}px")
	)
	$('#chart_wrapper').css('width',"#{$(window).width()-400}px")
	$('#chart').css('width',"#{$(window).width()-400}px")
	doneResizing = ->
		$('#chart_wrapper').css('width',"#{$(window).width()-400}px")
		$('#chart').css('width',"#{$(window).width()-410}px")
		makeChart()


	#load options.json
	$.ajax(
		url:'static/options.json'
		dataType: 'json'
		success: (response) ->  (
			options = response
			console.log options
			
			initializeSelectBoxes()
			newSlider()
			firstQuery()
		)
	)

	checkForLink = ->
		qt =	$.URLDecode((window.location.href).split("?")[1])
		return null if (qt==undefined or qt=='')
		qt = qt.replace /#/g,''
		JSON.parse(qt)

	firstQuery = ->
		console.log 'qt'
		l = checkForLink()
		console.log l
		if l!=null
			$('#main_select').val(l['comparison'])

			terms = l['terms']
			for i in [1...terms.length]
				console.log terms.length
				$('#plus_word').click()
			$('input.ngrams').each((i,v) ->
				$(v).val(terms[i])
			)
			cat_data = l['category_data']
			for i in [1...cat_data.length]
				$('#plus').click()

			$('.cat_div').each((i,v) ->
				$("select",v).each((i2,v2) ->
					cat_arr = cat_data[i][i2]
					console.log 'catarr'
					console.log cat_arr
					for el in cat_arr[1]
						$("option[value='#{el}']",v2).attr('selected','selected')
					$(v2).trigger('liszt:updated')
				)
			)
			$('#yeartype').val(l['query']['time_measure'])
			newSlider()
			for i in [0..1]
				$('#year-slider').slider('values',i,l['query']['time_limits'][i])

			$("#years").val "#{$('#year-slider').slider('values',0)} - #{$('#year-slider').slider('values',1)} "
			$('#colltype').val(l['query']['words_collation'])
			$('#collationtype').val(l['query']['counttype'])
			$('#smoothing').val(l['query']['smoothingSpan'])
			fixSlugs()
			fixGroupSelectWithoutAdd()
			console.log l['terms']
		else
			$('input.ngrams').val('Boston')

		runQuery()

	#initializes options boxes
	initializeSelectBoxes = ->
		$('.group_select_div').append '<select class=group_select> </select>'
		$('.limit_select_div').append '<select class=group_select> </select>'
		option_names = options['sort_order']
		option_array = (options['descriptions'][option_name] for option_name in option_names)
		#time selection
		for option in option_array when option['type']=='time'
			$('#yeartype').append "<option value='#{option['dbfield']}'>#{option['name']}</option"

		#fix ui
		fixGroupSelect()
	#image html strings
	xImg = '<input type="image" src="static/images/x.png" height=12 width=12 class=x></input>'

	#add new words box click
	$('#plus_word').click ->
		console.log 'wordplusclicked'
		numWordBoxes++
		$('.terms tbody').append('<tr class=term_tr></tr>')
		$('tr.top td.ngrams').clone()
			.appendTo('.terms tr:last')
		$('<td class=color><span class=color><div class=color></div></span> </td>')
			.appendTo('.terms tr:last')

		$("<td>#{xImg}</td>")
			.css('vertical-align','middle')
			.appendTo('.terms tr:last')
		
		fixWordColors()

	#event for group-by select change
	$('#main_select').change -> fixGroupSelect()
	#fix group select
	fixGroupSelect = ->
		newval = $('#main_select').val()
		numCatBoxes = 0
		numWordBoxes = 1
		$('.box_tr').remove()
		$('.cat_div').remove()
		$('.term_tr').remove()
		$('div.color').remove()
		#fix UI if splitting by words
		if newval!='word'
			$('#define_label').html('collections')
			$('#plus').show()
			$('#plus').click()
			$('#plus').click()
			$('#plus_word').hide()
		if newval=='word'
			$('#define_label').html('collection')
			$('#plus').hide()
			$('#plus_word').show()
			$('#plus').click()
			$('.terms tr.top td.color').append('<div class=color></div>')
			#kill x
			$('.category_box td.category_box_x').remove()
			#$('.category_box .category_box_row td').css('border-radius', '3px')
			fixWordColors()
	
	fixGroupSelectWithoutAdd = ->
		newval = $('#main_select').val()
		#fix UI if splitting by words
		if newval!='word'
			$('#define_label').html('collections')
			$('#plus').show()
			$('#plus_word').hide()
			$('div.color').remove()
		if newval=='word'
			$('#define_label').html('collection')
			$('#plus').hide()
			$('#plus_word').show()
			fixWordColors()


	#word input key functions
	$('input.ngrams').live('keydown',
		(event) ->
			#tabbing
			if event.keyCode == 9
				event.preventDefault()
				if not event.shiftKey
					$(":input.ngrams:eq(#{$(':input.ngrams').index(this) + 1})").focus()
				if event.shiftKey
					$(":input.ngrams:eq(#{$(':input.ngrams').index(this) - 1})").focus()

			#enter
			if event.keyCode == 13
				runQuery()
			if event.keyCode == 32
				event.preventDefault()
	)

	#change for yeartype
	$('#yeartype').change ->
		newSlider()

	#newSlider
	newSlider = ->
		year_option = options['descriptions'][$('#yeartype').val()]
		console.log year_option
		$('#year-slider').slider(
			range: true
			min: year_option['numeric']['range'][0]
			max: year_option['numeric']['range'][1]
			values: year_option['numeric']['defaults']
			slide: (event, ui) ->
				$("#years").val "#{ui.values[0]} - #{ui.values[1]}"
		)
		$("#years").val(year_option['numeric']['defaults'].join(' - '))

	#live for wordinput x buttons
	$('input.x').live(
		'click',
		->
			$(this).parents('tr.term_tr').remove()
			fixWordColors()
			numWordBoxes--
	)

	#x-buttons for split-cat boxes
	$('.category_box a.box_x').live('click', ->
		$(this).parents('.box_tr').remove()
		#grab box_id from div
		box_id = $(this).parents('span.category_box').attr('id').split('_')[2]
		$("#wrapper_cat_div_#{box_id}").remove()
		fixColors()
	)

		
	#handle adding new comparison fields
	$('#plus').click ->
		numCatBoxes++
		$('#cat_boxes table.top').append('<tr class=box_tr> <td class=box_td></td></tr>')
		$('#category_box_template')
			.clone().removeClass('category_box_template').addClass('category_box')
			.attr('id',"cat_box_#{numCatBoxes}")
			.appendTo('#cat_boxes tr.box_tr:last td.box_td')
		$("#cat_box_#{numCatBoxes} .box_data").html("None")
		fixColors()
		createCategoryDiv()
		fixSlugs()

	fixColors = ->
		if $('#main_select').val() == 'texts'
			$('.category_box').each ((i,v) ->
				$(this).find("tbody").css('background-color',"rgba(#{colors[i+1]},1)")
			)
		if $('#main_select').val() == 'word'
			$('.category_box').each ((i,v) ->
				$(this).find("tbody").css('background-color',"#CCCCCC")
			)
	fixWordColors = ->
		$('div.color').each ((i,v) ->
			$(this).css('background-color',"rgba(#{colors[i+1]},1)")
		)

	#handle new category divs
	createCategoryDiv = ->
		divName = "cat_div_#{numCatBoxes}"
		$('<div></div>').css('display','none').attr('id',"wrapper_#{divName}").addClass('cat_div').appendTo('body')
		$('<div></div>').attr('id',divName).data('box_num',"#{numCatBoxes}").addClass('sub_cat_div').css('display','').appendTo("#wrapper_#{divName}")
		$("##{divName}").append(divName)
		$("#cat_box_#{numCatBoxes} a.box_edit").colorbox(
				width: '50%'
				height: '80%'
				inline: true
				href: "##{divName}"
		)
		addFormToDiv(divName)


	#make those popup divs have forms
	addFormToDiv = (divName) ->
		divName = "##{divName}"
		$(divName).html('')
		$(divName).append("<h3>Define Corpus</h3><hr />")
		$(divName).append('<table><tr></tr></table>')
		for option_name in options['sort_order']
			option = options['descriptions'][option_name]
			if option['type'] == 'categorical'
				$("#{divName} table").append("<tr class=datarow></tr>")
				$("#{divName} tr:last").data('name',option['dbfield'])
				$("#{divName} tr:last").data('shortname',option_name)
				option_nlist = option['categorical']['sort_order']
				option_list = option['categorical']['descriptions']
				$("#{divName} tr:last").append("<td><span class=labeler>#{option['name']}:</span></td>")
				$("#{divName} tr:last").append("<select class=popup multiple=multiple style='width:350px;'></select>")
				for option_n in option_nlist
					$("#{divName} tr:last select").append($("<option value=#{option_list[option_n]['dbcode']}>#{option_list[option_n]['name']}</option>").data('shortname',option_n))

		$("#{divName} select").data('placeholder','All').chosen().change( -> slug($(this).parents('.sub_cat_div').attr('id')))
	
	fixSlugs = ->
		$('.sub_cat_div').each( (i,v) ->
			slug($(v).attr('id'))
		)

			
	#get slug for box
	getSlug = (divName) ->
		a = getChecked "##{divName}"
		good_opts = (op for op in a when op[1].length !=0)
		#for i in [0...good_opts.length]
	#		for j in [0...good_opts[i][1].length]
		#		if good_opts[i][1][j].indexOf(':')!=-1
			#			good_opts[i][1][j] = good_opts[i][1][j].split(':')[1]
		console.log good_opts
		optlist = []
		if good_opts.length==0
			return 'All books'
		for good_opt in good_opts
			opt_text = ''
			if good_opt[1].length==1
				 opt_text = good_opt[1][0]
			if good_opt[1].length==2
					opt_text = good_opt[1].join(', ')
			if good_opt[1].length>=3
				opt_text = "#{good_opt[1][0]}, [#{good_opt[1].length-2} more], #{good_opt[1][good_opt[1].length-1]}"
			optlist.push([good_opt[0],opt_text])#([good_opt[0], opt_text])
		return (op.join(': ') for op in optlist).join(' | ')
	
	getChecked = (divName) ->
		cats = []
		$(divName).find("tr.datarow").each( (i2, v2) ->
			cats.push [$(v2).data('shortname'),($(v).data('shortname') for v in $(v2).find('option:selected'))]
		)
		cats

	#slugs for little boxes
	slug = (divName) ->
		slugText=getSlug divName
		console.log slugText
		divvy=divName.split('_')
		if divvy['0']=='cat'
			boxDiv="#{divvy[0]}_box_#{divvy[2]}"
			console.log boxDiv
			$("##{boxDiv} .box_data").html(slugText)

	
	#colorbox for help
	$('a.help').colorbox(
				width: '80%'
				height: '90%'
				href: "help.html"
	)
	#colorbox for about
	$('a.about').colorbox(
				width: '80%'
				height: '90%'
				href: "about.html"
	)
	#build the query!
	buildQuery = ->
		search_limits = []
	
		main_choice = $('#main_select').val()
		if main_choice=='word'
			terms =  ($(elt).val().split(',') for elt in $('input.ngrams'))
			cats = []
			$('.cat_div').each ((i,v) ->
				$(v).find("tr.datarow").each( (i2, v2) ->
					cats.push [$(v2).data('name'),($(v).val() for v in $(v2).find('option:selected'))]
				)
			)

			console.log terms
			console.log 'cats'
			console.log cats
			index = 0
			for term in terms
				new_limits =
					word: term
				for cat in cats
					if cat[1].length != 0
						new_limits[cat[0]]=cat[1]
				search_limits.push new_limits
		if main_choice=='texts'
			terms =  ($(elt).val().split(',') for elt in $('input.ngrams'))
			term = terms[0]
			cats = []
			$('.cat_div').each ((i,v) ->
				cat_arr = []
				$(v).find("tr.datarow").each( (i2, v2) ->
					cat_arr.push [$(v2).data('name'),($(v).val() for v in $(v2).find('option:selected'))]
				)
				cats.push cat_arr
			)

			console.log terms
			console.log cats
			index = 0
			for cat_arr in cats
				search_limit =
					word: term
				for cat in cat_arr
					if cat[1].length != 0
						search_limit[cat[0]]=cat[1]
				search_limits.push search_limit
		query =
			index: 0
			time_measure:  $('#yeartype').val()
			time_limits: [$('#year-slider').slider("values", 0),$('#year-slider').slider("values",1)]
			counttype: $('#collationtype').val()
			words_collation: $('#colltype').val()
			smoothingSpan: $('#smoothing').val()
			search_limits: search_limits
		console.log 'query'
		console.log JSON.stringify(query)
		return query

	#hashing for permalinks
	permQuery = ->
		q = buildQuery()
		terms = ($(x).val() for x in $('input.ngrams'))
		cats = []
		$('.cat_div').each ((i,v) ->
			cat_arr = []
			$(v).find("tr.datarow").each( (i2, v2) ->
				cat_arr.push [$(v2).data('name'),($(v).val() for v in $(v2).find('option:selected'))]
			)
			cats.push cat_arr
		)
		obj =
			query: q
			terms: terms
			category_data: cats
			comparison: $('#main_select').val()
		console.log(obj)
		"/beta/?#{$.URLEncode(JSON.stringify obj)}"
	#view query code
	$('#seequery').click ->
		$('#querycode').html permQuery()
		$.colorbox(
			width: '75%'
			inline: true
			href: "#querycode"
		)

	#validateQuery
	validateQuery = ->
		flag = false
		error = ''
		$('input.ngrams').each( (i,v) ->
			if $(v).val() == ''
				error = 'Word input empty.'
				flag = true
		)
		if not flag
			$('#errors p').html('')
		if flag
			$('#errors p').html(error)
		return not flag

	#post query code
	$('#submit-query').click ->
		(return false) unless validateQuery()
		#loading symbol
		runQuery()
	runQuery = ->
		$('#chart').html('')
		$('#chart').addClass('loading')
		query = buildQuery()
		data = []
		$('#chart').ajaxStop(makeChart)
		console.log query
		$.ajax (
			url: '/cgi-bin/corebindings.py'
			data: {method: 'return_query_values', queryTerms: (JSON.stringify query)}
			dataType: 'html'
			success: (response)->
				console.log response
				actual_string = response.split('===RESULT===')[1]
				data = eval actual_string
		)
		console.log('permQuery')
		window.history.replaceState("object or string", "Title", "#{permQuery()}")


	makeChart = ->
		numSeries=0
		$('#chart').removeClass('loading')
		$("#chart").html(data.toString())
		console.log data
		#axis labels
		xAxisLabel = $('#yeartype option:selected').text()#data[0]['options']['xlab']
		yAxisLabel = $('#collationtype option:selected').text() #data[0]['options']['ylab']
		xmin =  $('#year-slider').slider('values',0)
		xmax =  $('#year-slider').slider('values',1)
		
		seriesArr = data
		console.log 'series'
		console.log seriesArr

		series = []
		for s in data
			vals = s['values']
			console.log vals
			sdata = []
			for year in [xmin..xmax] when (vals.hasOwnProperty year)
				opts = {n: numSeries, t: year}
				sdata.push {x: year, y:parseFloat(vals[year]), opts: opts}
			console.log s
			numSeries++
			serie =
				name: s['Name']
				data: sdata
				color: hexColors[numSeries]
			series.push serie
		console.log series

		chart = new Highcharts.Chart({
			chart:
				renderTo: 'chart'
				type: 'line'
			title:
				text: null
			xAxis:
				title:
					text: xAxisLabel
				labels:
					formatter: -> this.value
				min: $('#year-slider').slider('values',0)
				max: $('#year-slider').slider('values',1)
			yAxis:
				title:
					text: yAxisLabel
				min: 0
			legend:
				enabled: false
			series: series
			plotOptions:
				line:
					animation: true
				series:
					marker:
						radius: 1
					cursor: 'pointer'
					events:
						click: (event) ->
							name = this.name
							titleString = "Books for series #{name} matching constraints in #{event.point.opts.t}"
							$('#bookdivtitle').html(titleString)
							console.log 'clicked'
							query = buildQuery()
							console.log 'opts'
							console.log event.point.opts
							query['search_limits']=[query['search_limits'][event.point.opts['n']]]
							query['search_limits'][0][query['time_measure']]=[event.point.opts['t']]
							console.log JSON.stringify(query)
							$.ajax(
								url: '/cgi-bin/corebindings.py'
								type: 'post'
								data: {method: 'return_books', queryTerms: JSON.stringify(query)}
								success: (response) ->
									response = response.split('===RESULT===')[1]
									console.log response
									dataArray = eval(eval(response)[0])
									console.log dataArray
									bookLinks=[]
									for linkData in dataArray
										cat_link = "<a class=booklink href='#{linkData['cat_url']}' target='_blank'>More info</a>"
										read_link = "<a class=booklink href='#{linkData['read_url']}' target='_blank'>Read</a>"
										row = "<tr><td><img src='#{linkData['cover-image']}' width=44 height=58 /></td><td><span class=booktitle>#{linkData['title']}</span><span class=bookauthor> by #{linkData['author']}</span> #{cat_link} #{read_link}</tr>"
										bookLinks.push row

									$('#pagination').pagination(dataArray.length, {items_per_page: 10, callback: handlePaginationClick});
									$('#bookdiv').html('<table></table>')
									for i in [0...Math.min(6,dataArray.length)]
										$('#bookdiv table').append(bookLinks[i])
									
									$.colorbox({width: '90%', inline: true, href: '#books'})
								
							)
																	
			tooltip:
				formatter: ->
					point = this.point
					return "<b>#{point.series.name}</b><br />Year: #{point.x} <br />Freq: #{point.y}<br /><b>Click for books</b>"
		})
#
		handlePaginationClick = (new_page_id, pagination_container) ->
			$('#bookdiv').html('<table></table>')
			for i in [new_page_id*10...(new_page_id+1)*10]
				$('#bookdiv table').append(bookLinks[i])
			false
)
