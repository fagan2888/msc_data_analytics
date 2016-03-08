// d3.js charts by Maria Athena B Engesaeth
// tutorial/inspiration from: http://square.github.io/intro-to-d3/examples/

var csvFile = './data/OlympicData.csv';
var yearClicked = '2012';
var formattedData;


///////////////////////////////////////////////////////////////////
///////////////  INSTANTIATE & INTERACTIVITY  /////////////////////
///////////////////////////////////////////////////////////////////


// Instantiating the data prep and visualisations
d3.csv(csvFile, function(data) {

  // Format data for first visualisation
  cleanData(data);
	var stackedData = formatStackedData(data);
	// Format data for second visualisation
  formattedData = formatStackedMedalData(data);
  var stackedTwoData = sortStackedYearData(formattedData[yearClicked], 3);

  // Draw first visualisation
	drawStackedGraph(stackedData);
  // Draw second visualisation
  drawStackedMedalGraph(stackedTwoData);

//  //tests/view formatted data in console
//  console.log(stackedData);
//  console.log(formattedData[yearClicked]);
//  console.log(stackedTwoData);
  
});


// //listenforclicksongraph(
// element.attachEvent('onclick', function() {
//   var yearClicked = '2012';

//   // when first graph is clicked
//   if {
//     drawStackedGraph.yearClicked
//     return yearClicked
//   }
  
//   // take the year that was clicked

//   // call the sort method
//   sortStackedYearData(formattedData[yearClicked], 10);

// });

// var stackedTwoData = sortStackedYearData(formattedData[yearClicked], 10);

//console.log(JSON.stringify(sortStackedYearData(formatStackedMedalData(data)['2010'], 10)));


///////////////////////////////////////////////////////////////////
///////////Data Formatting for first visualisation/////////////////
///////////////////////////////////////////////////////////////////

function formatStackedData(data) {

	var stackedDataByGender = {
		MEN: {},
		WOMEN: {}
	};

	loopOverData(data, function(record) {
		var gender = genderInRecord(record);

		increaseMedalDataForType(record, stackedDataByGender[gender]);
	});

	normalizeHashes(stackedDataByGender.MEN, stackedDataByGender.WOMEN);
	
	return [
		{
			name: 'MEN',
			values: formatHashesByMedalData(stackedDataByGender.MEN)
		},
		{
			name: 'WOMEN',
			values: formatHashesByMedalData(stackedDataByGender.WOMEN)
		}
	];
}


function genderInRecord(record) {
	return record.Gender;
}


function cleanData(data) {
	var wantedFields = {
		'Games': true,
		'Gender': true,
		'CountryName': true,
		'Medal': true
	};

	loopOverData(data, function(record) {
		formatGamesToNumber(record);
		keepWantedFields(record, wantedFields);
	});
}


function formatGamesToNumber(record) {
	record.Games = parseInt(record.Games, 10);
}


function keepWantedFields(record, wantedFields) {
	for (var field in record) {
		if (record.hasOwnProperty(field) && wantedFields[field] !== true) {
			delete record[field];
		}
	}
}


function loopOverData(data, callback) {
	data.forEach(callback);
}


function increaseMedalDataForType(record, tally) {
	if (tally.hasOwnProperty(record.Games)) {
		tally[record.Games] += 1;
	}
	else {
		tally[record.Games] = 1;
	}
}


function formatHashesByMedalData(hash) {
	var medalData = [];

	for (var key in hash) {
		medalData.push({count: hash[key], year: parseInt(key, 10)});
	}

	return medalData;
}


function normalizeHashes(hashA, hashB) {
	var addToHash = function(hash, key) {
		if ( ! hash.hasOwnProperty(key)) {
			hash[key] = 0;
		}
	};

	for (var key in hashA) {
		addToHash(hashB, key);
	}

	for (var key in hashB) {
		addToHash(hashB, key);
	}
}



///////////////////////////////////////////////////////////////////
///////////Data Formatting for second visualisation////////////////
///////////////////////////////////////////////////////////////////


function formatStackedMedalData(data) {
  var stackedTwoData = {};
  
  for (var i = 0; i < data.length; i++) {
    var d = data[i];
    
    var yearData = getSectionByYear(d.Games, stackedTwoData);
    var medalSection = getMedalSectionByType(d.Medal, yearData);
    var countryRecord = getCountryMedalRecord(d.CountryName, medalSection);
    
    addMedalEntry(countryRecord);
  }
  
  return stackedTwoData;
}


function sortStackedYearData(data, limit) {
  var groupedData = groupByCountry(data);
  var medalTally = tallyByCountry(groupedData);
  var sortedMedalTally = sortMedalTally(medalTally); 
  var sliced = sortedMedalTally.slice(0, limit);

  return stackedDataFromGrouped(groupedData, sliced);
}

function stackedDataFromGrouped(groupedData, topTen) {
  var stackedTwoData = [
    {name:'Gold', values:[]}
    , {name:'Silver', values:[]}
    , {name:'Bronze', values:[]}
  ];
  
  for (var i = 0; i < topTen.length; i++) {
    var country = topTen[i].country;
    for (var j = 0; j < stackedTwoData.length; j++) {
      var medal = stackedTwoData[j].name;
      
			stackedTwoData[j].values.push((groupedData[country].hasOwnProperty(medal))
				? groupedData[country][medal]
				: createCountryRecord(country));
    }
  }
  
  return stackedTwoData;
}

function sortMedalTally(medalTally) {
  return medalTally.sort(function(a, b) {
    return (a.count > b.count)
      ? -1
      : (a.count < b.count)
        ? 1
        : 0;
  });
}

function groupByCountry(data) {
  var grouped = {};
  
  for (var i = 0; i < data.length; i++) {
    for (var j = 0; j < data[i].values.length; j++) {
      var d = data[i].values[j];
      if ( ! grouped.hasOwnProperty(d.country)) {
        grouped[d.country] = {};
      }
      grouped[d.country][data[i].name] = d;
    }
  }
  
  return grouped;
}

function tallyByCountry(groupedData) {
  var tally = [];
  
  for (var country in groupedData) {
    var countryCount = {country:'', count:0};
    countryCount.country = country;
    tally.push(countryCount);
    for (var medal in groupedData[country]) {
      countryCount.count += groupedData[country][medal].count;
    }
  }
  
  return tally;
}

function getSectionByYear(year, stackedTwoData) {
  if ( ! stackedTwoData.hasOwnProperty(year)) {
    stackedTwoData[year] = [];
  }
  return stackedTwoData[year];
}


function getMedalSectionByType(medal, yearData) {
  for (var i = 0; i < yearData.length; i++) {
    if (yearData[i].name == medal) {
      return yearData[i];
    }
  }
  
  var medalSection = {
    name: '',
    values: []
  };
  medalSection.name = medal;
  
  yearData.push(medalSection);
  
  return medalSection;
}

function getCountryMedalRecord(country, medalSection) {
  var values = medalSection.values;
  
  for (var i = 0; i < values.length; i++) {
    if (values[i].country == country) {
     return values[i];
    }
  }
  
  var countryRecord = createCountryRecord(country);
  
  medalSection.values.push(countryRecord);
  
  return countryRecord;
}

function addMedalEntry(countryRecord) {
  countryRecord.count += 1;
  
  return countryRecord;
}

function createCountryRecord(country) {
  var countryRecord = {
    count: 0,
    country: ''
  };
  countryRecord.country = country;

	return countryRecord;
}



///////////////////////////////////////////////////////////////////
//////////////////////First visualisation//////////////////////////
///////////////////////////////////////////////////////////////////


// The TOP visualisation showing medals by gender in all modern
// Olympic Games 1896 - 2012
function drawStackedGraph(stackedData) {
	var stack = d3.layout.stack()
		.values(function(d) { return d.values; })
		.x(function(d) { return d.year; })
		.y(function(d) { return d.count; })
		.order('reverse');

	// Variable containing the data in d3
	var stacked = stack(stackedData);

	// SVG sizing variables
	var height = 400;
	var width = 500;
	var barCount = stacked[0].values.length;
	var padding = 40;
	var barSpacing = 6;
	// Legend sizing
	var legendHeight = 100;
	var legendWidth = 100;
	var legendRectSize = 18;
	var legendSpacing = 4;


	var maxY = d3.max(stacked, function(d) {
		return d3.max(d.values, function(d) {
				return d.y0 + d.y;
			});
		});


	// Define scales for the axes
	var y = d3.scale.linear()
		.range([height, 0])
		.domain([0, maxY]);

	var x = d3.scale.ordinal()
		.rangeRoundBands([padding/2, width - padding/2], .1)
		.domain(stacked[0].values.map(function(d) {
		return d.year;
	}));


  // Declare html <div> for tooltips
  // var svg = d3.select("visualisations")
  //   .append("drawStackedGraph")
  //   .attr("class", "tooltips")
  //   .style("opacity", 0); 

	// Create SVG container in the html <body> container
	var svg = d3.select("#drawStackedGraph")
		.append("svg")
			// .attr('width', width + (barCount - 1) * padding + 120)
			.attr('width', width + 100)
			.attr('height', height + 100)
			// .attr('padding', padding)
			.append("g")
			// Specify change to unhide yAxis
      // .attr("transform", "translate"(70, 20));
			.attr("transform", "translate(" + 70 + "," + 20 +")");
	
	var color = d3.scale.ordinal()
		.range(["#add8e6", "#ffc0cb"]);


	// Define the axes
	var xAxis = d3.svg.axis()
    	.scale(x)
    	.orient("bottom")
    	.tickSize(.5);

	var yAxis = d3.svg.axis()
    	.scale(y)
    	.orient("left")
    	.ticks(10);


    // Create the axes
  	// The yAxis
  	svg.append("g")
      	.attr("class", "axis axis--y")
      	// Move axis closer to graph
      	.attr("transform", "translate(" + 25 + ",0)")
      	.call(yAxis)
		.selectAll("text")
  			.style("text-anchor", "end")
  			.style("fill", function (d) { return '#585858'; });
    // Add title
    svg.append("text")
        .attr("text-anchor", "middle")
        .attr("transform", "translate("+ (-padding/2) +","+(height/2)+")rotate(-90)")
        // text is drawn off the screen top left, move down and out and rotate
        .text("Medal Count")
        .style("fill", function (d) { return '#585858'; });

    // The xAxis
    svg.append("g")
      	.attr("class", "axis axis--x")
      	.attr("transform", "translate(0," + height + ")")
      	.call(xAxis)
      	// Rotate text on xAxis
      	.selectAll("text")
      		.style("text-anchor", "start")
      		.attr('dx', '.4em')
      		.attr('dy', '-.05em')
      		.attr("transform", function(d) { return "rotate(90)" })
      		.style("fill", function (d) { return '#585858'; });
	// Add title
    svg.append("text")
        .attr("text-anchor", "middle")
        .attr("transform", "translate("+ (width/2) +","+(height+(padding*1.3))+")")  // centre below axis
        .text("Year of Games")
        .style("fill", function (d) { return '#585858'; });


  // Create legend  
  var legend = svg.append("g")
		.attr("class", "legend")
		// .attr("x", w - 65)
		// .attr("y", 50)
		.attr("height", legendHeight)
		.attr("width", legendWidth);

  // <----------- tooltips
  // Create tooltips
  // var formatTip = d3.time.format("%e %B");

  var div = d3.select("body").append("div")
    .attr("class", "tooltip") 
    .style("opacity", 0);

  // var tip = d3.tip()
  //   .attr('class', 'd3-tooltip')
  //   .offset([-10, 0]);

  // svg.call(tip)


	// The rectangles showing the colour coding
	legend.selectAll('rect')
		.data(stacked)
		.enter()
		.append("rect")
		.attr("x", legendWidth - 65)
		.attr("y", function(d, i) {
			return i * 20;
		})
		.attr("width", legendRectSize)
		.attr("height", legendRectSize)
		.attr("fill", function(d) { return color(d.name); });
      // <----------- tooltips
      // .on("mouseover", function(d) {
      //   div.transition()
      //   .duration(200)
      //   .style("opacity", .9);
      // div.html(formatTime(d.date) + "<br/>" + d.close )
      //   .style("left", (d3.event.pageX) + "px")
      //   .style("top", (d3.event.pageY - 28) + "px")
      // })
      // .on("mouseout", function(d) {
      //   .duration(500)
      //   .style("opacity", 0);
      // });

		// .style("fill", function(d) {
		// 	var color = colors[stacked.indexOf(d)][1];
		// 	return color;
		// });
	
	// Get the text for the legend
	// legend.selectAll('text')
	// 	.data(stacked)
	// 	.enter()
	// 	.append("text")
		// .attr("transform", "translate(-100,100)")
		// .attr("x", legendWidth - 40)
		// .attr("y", legendRectSize/2)
		// .text("WOMEN")
		// .attr("x", legendWidth - 40)
		// .attr("y", legendRectSize/2)
		// .attr("y", function(d, i) {
		// 	return i * 10 ;
		// })
		// .style("fill", function (d) { return '#585858'; })
		// .text(function(d) { 
		// 	for ( key in stacked.keys(d) ) {
		// 		var text = key
		// 		return text;
		// 	}
		// });
	legend.append('text')
		.text("MEN")
		.attr("x", legendWidth - 40)
		.attr("y", legendRectSize/1.85)
	legend.append('text')
		.text("WOMEN")
		.attr("x", legendWidth - 40)
		.attr("y", legendRectSize*1.9)

	// Create graph: layers for the actual stacked bars
	var layers = svg.selectAll("g.layer")
		.data(stacked, function(d) { return d.name; })
		.enter()
		.append("g")
		.attr('class', 'layer')
		.attr("fill", function(d) { return color(d.name); });

	layers.selectAll("rect")
		.data(function(d) { return d.values; })
		.enter()
		.append("rect")
		.attr("x", function(d) {return x(d.year); })
		.attr('width', width / barCount - barSpacing)
		.attr("y", function(d) { return y(d.y0 + d.y); })
		.attr('height', function(d) { return height - y(d.y) })
		.on("click", function(d, i) {
			//redrawMedalData(sortStackedYearData(formattedData[d.year], 3));
			var stackedTwoData = sortStackedYearData(formattedData[d.year], 3);
			document.getElementById('drawStackedMedalGraph').innerHTML = '';
			drawStackedMedalGraph(stackedTwoData);
		});;

}



///////////////////////////////////////////////////////////////////
/////////////////////Second visualisation//////////////////////////
///////////////////////////////////////////////////////////////////


// The TOP THREE winning countries per year 
// visualisation showing medal type by country who won it
// Olympic Games 1896 - 2012
function drawStackedMedalGraph(stackedTwoData) {
  var stackTwo = d3.layout.stack()
    .values(function(d) { return d.values; })
    .x(function(d) { return d.country; })
    .y(function(d) { return d.count; })
    .order('reverse');

  // Variable containing the data in d3
  var stackedTwo = stackTwo(stackedTwoData);

  stackedTwo.sort(function(b, a) {
    return b.total - a.total; 
  });


  // SVG sizing variables
  var height = 400;
  var width = 500;
  var barCount = stackedTwo[0].values.length;
  var padding = 40;
  var barSpacing = 6;
  // Legend sizing
  var legendHeight = 100;
  var legendWidth = 100;
  var legendRectSize = 18;
  var legendSpacing = 4;


  var maxY = d3.max(stackedTwo, function(d) {
    return d3.max(d.values, function(d) {
        return d.y0 + d.y;
      });
    });


  // Define scales for the axes
  var y = d3.scale.linear()
    .range([height, 0])
    .domain([0, maxY]);

  var x = d3.scale.ordinal()
    .rangeRoundBands([padding/2, width - padding/2], .1)
    .domain(stackedTwo[0].values.map(function(d) {
    return d.country;
  }));


  //Create SVG container
  var svg = d3.select("#drawStackedMedalGraph")
    .append("svg")
      // .attr('width', width + (barCount - 1) * padding + 120)
      .attr('width', width + 100)
      .attr('height', height + 100)
      // .attr('padding', padding)
      .append("g")
      // Specify change to unhide yAxis
      .attr("transform", "translate(" + 70 + "," + 20 +")");
  
  var color = d3.scale.ordinal()
    .range(["#E8C819", "#999999", '#CD5832']);


  // Define the axes
  var xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom")
      .tickSize(.5);

  var yAxis = d3.svg.axis()
      .scale(y)
      .orient("left")
      .ticks(10);


    // Create the axes
    // The yAxis
    svg.append("g")
        .attr("class", "axis axis--y")
        // Move axis closer to graph
        .attr("transform", "translate(" + 25 + ",0)")
        .call(yAxis)
    .selectAll("text")
        .style("text-anchor", "end")
        .style("fill", function (d) { return '#585858'; });
    // Add title
    svg.append("text")
        .attr("text-anchor", "middle")
        .attr("transform", "translate("+ (-padding/2) +","+(height/2)+")rotate(-90)")
        // text is drawn off the screen top left, move down and out and rotate
        .text("Medal Count Split by Type")
        .style("fill", function (d) { return '#585858'; });

    // The xAxis
    svg.append("g")
        .attr("class", "axis axis--x")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis)
        // Rotate text on xAxis
        .selectAll("text")
          .style("text-anchor", "end")
          // .attr('dx', '.4em')
          // .attr('dy', '-.05em')
          .attr("transform", function(d) { return "rotate(0)" })
          .style("fill", function (d) { return '#585858'; });
  // Add title
    svg.append("text")
        .attr("text-anchor", "middle")
        .attr("transform", "translate("+ (width/2) +","+(height+(padding*1.3))+")")  // centre below axis
        .text("Top Three Winning Countries")
        .style("fill", function (d) { return '#585858'; });


  // Create legend  
  var legend = svg.append("g")
    .attr("class", "legend")
    // .attr("x", 65)
    // .attr("y", 50)
    .attr("height", legendHeight)
    .attr("width", legendWidth);

  // The rectangles showing the colour coding
  legend.selectAll('rect')
    .data(stackedTwo)
    .enter()
    .append("rect")
    .attr("x", 370)  
    .attr("y", function(d, i) {
      return i * 20;
    })
    .attr("width", legendRectSize)
    .attr("height", legendRectSize)
    .attr("fill", function(d) { return color(d.name); });
  
  // Set the text for the legend
  legend.append('text')
    .text("GOLD")
    .attr("x", 400)
    .attr("y", legendRectSize/1.3)
  legend.append('text')
    .text("SILVER")
    .attr("x", 400)
    .attr("y", legendRectSize*1.9)
  legend.append('text')
    .text("BRONZE")
    .attr("x", 400)
    .attr("y", legendRectSize*3.1)


  // Create graph: layers for the actual stackedTwo bars
  var layers = svg.selectAll("g.layer")
    .data(stackedTwo, function(d) { return d.name; })
    .enter()
    .append("g")
    .attr('class', 'layer')
    .attr("fill", function(d) { return color(d.name); });

  layers.selectAll("rect")
    .data(function(d) { return d.values; })
    .enter()
    .append("rect")
    .attr("x", function(d) {return x(d.country); })
    .attr('width', width / 5 - barSpacing)
    .attr("y", function(d) { return y(d.y0 + d.y); })
    .attr('height', function(d) { return height - y(d.y) });

}
