/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
var margin = { top: 30, right: 160, bottom: 50, left: 60 },
    width = 480 - margin.left - margin.right,
    height = 400 - margin.top - margin.bottom;

// append the svg object to the body of the pagevar svg = d3.select("#my_dataviz")
var svg = d3
    .select("#my_dataviz")
    .style("margin", "auto")
    .style("display", "flex")
    .style("flex-direction", "column")
    .style("align-items", "center")
    .style("justify-content", "center")
    .append("svg")
    .style("order", 2)
    .style("border", "solid")
    .style("border-width", "1px")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

//Read the data
d3.json("Scatterplot.json", function (data) {
    //Extract data
    const title = data.graphName;
    const xLabel = data.xAxisLabel;
    const yLabel = data.yAxisLabel;
    const values = Object.values(data.data);

    //Define Xaxis
    var x = d3
        .scaleLinear()
        .domain(d3.extent(values, (d) => d.x))
        .range([0, width]);
    var xAxis = svg
        .append("g")
        .attr("transform", "translate(0," + height + ")")
        .call(d3.axisBottom(x));

    svg.append("text")
        .text(xLabel)
        .attr("x", width / 3)
        .attr("y", height + 30)
        .style("font-size", "15px");

    // Add Y axis
    var y = d3
        .scaleLinear()
        .domain(d3.extent(values, (d) => d.y))
        .range([height, 0]);
    var yAxis = svg.append("g").call(d3.axisLeft(y));

    svg.append("text")
        .text(yLabel)
        .attr("y", -30)
        .attr("x", -(height / 3))
        .style("text-anchor", "end")
        .attr("transform", "rotate(-90)")
        .style("font-size", "15px");

    // Color scale: give me a specie name, I return a color
    var color = d3
        .scaleOrdinal()
        .domain(values.map((value) => value.name))
        .range(["#440154ff", "#21908dff", "#fde725ff"]);

    // Add a clipPath: everything out of this area won't be drawn.
    var clip = svg
        .append("defs")
        .append("SVG:clipPath")
        .attr("id", "clip")
        .append("SVG:rect")
        .attr("width", width)
        .attr("height", height)
        .attr("x", 0)
        .attr("y", 0);

    // Create the scatter variable: where both the circles and the brush take place
    var scatter = svg.append("g").attr("clip-path", "url(#clip)");

    // Set the zoom and Pan features: how much you can zoom, on which part, and what to do when there is a zoom
    var zoom = d3
        .zoom()
        .scaleExtent([0.5, 20]) // This control how much you can unzoom (x0.5) and zoom (x20)
        .extent([
            [0, 0],
            [width, height],
        ])
        .on("zoom", updateChart);

    // This add an invisible rect on top of the chart area. This rect can recover pointer events: necessary to understand when the user zoom
    scatter
        .append("rect")
        .attr("width", width)
        .attr("height", height)
        .style("fill", "none")
        .style("pointer-events", "all")
        .lower();

    scatter.call(zoom);
    // now the user can zoom and it will trigger the function called updateChart

    // A function that updates the chart when the user zoom and thus new boundaries are available
    function updateChart() {
        // recover the new scale
        var newX = d3.event.transform.rescaleX(x);
        var newY = d3.event.transform.rescaleY(y);

        // update axes with these new boundaries
        xAxis.call(d3.axisBottom(newX));
        yAxis.call(d3.axisLeft(newY));

        // update circle position
        scatter
            .selectAll(".points")
            .attr("cx", function (d) {
                return newX(d.x);
            })
            .attr("cy", function (d) {
                return newY(d.y);
            });
    }

    // Add dots
    scatter
        .selectAll(".mypoint")
        .data(values)
        .enter()
        .append("circle")
        .classed("points", true)
        .attr("id", "mypoint")
        .attr("x-value", function (d) {
            return d.x;
        })
        .attr("y-value", function (d) {
            return d.y;
        })
        .attr("cx", function (d) {
            return x(d.x);
        })
        .attr("cy", function (d) {
            return y(d.y);
        })
        .attr("r", 3)
        .style("fill", function (d) {
            return color(d.name);
        })
        .on("mouseover", function (d) {
            tooltip
                .style("opacity", 0.8)
                .html(d.name + " (" + d.x + "," + d.y + ")")
                .style("left", event.pageX + 5 + "px")
                .style("top", event.pageY + "px");
        })
        .on("mouseout", function (d) {
            tooltip.transition(200).style("opacity", 0);
        });

    var tooltip = d3
        .select("body")
        .append("div")
        .attr("id", "tooltip")
        .style("opacity", 0)
        .style("position", "absolute")
        .attr("class", "tooltip")
        .style("background-color", "white")
        .style("border", "solid")
        .style("border-width", "1px")
        .style("border-radius", "5px")
        .style("padding", "10px");

    //Legends
    var legendContainer = svg.append("g").attr("id", "legend");

    var legend = legendContainer
        .selectAll("#legend")
        .data(color.domain())
        .enter()
        .append("g")
        .attr("class", "legend-lable")
        .attr("transform", function (d, i) {
            return "translate(0," + (height / 2 - i * 20) + ")";
        });

    legend
        .append("circle")
        .attr("cx", width + margin.right - 120)
        .attr("r", 5)
        .style("fill", color);

    legend
        .append("text")
        .attr("x", width + margin.right - 110)
        .attr("y", 1)
        .attr("dy", ".35em")
        .text(function (d) {
            return d;
        });

    //        create title
    d3.select("#my_dataviz")
        .append("div")
        .html(title)
        .style("text-align", "center")
        .style("order", 1)
        .style("font-size", "18px")
        .style("margin-bottom", "1rem");
});
