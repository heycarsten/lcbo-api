import Em from 'ember';

export default Em.Component.extend({
  classNames: 'bar-chart',
  height: 340,
  color: '#9C27B0',

  draw: function() {
    var graph;
    var data;
    var xAxes;
    var yAxes;
    var detail;

    data = this.get('data').map(function(d) {
      return {
        x: moment(d[0]).unix(),
        y: d[1]
      };
    });

    graph = new Rickshaw.Graph({
      element: this.get('element'),
      width:   this.get('width'),
      height:  this.get('height'),
      renderer: 'bar',
      xScale: d3.time.scale(),
      stroke: true,

      padding: {
        top: 0.01,
        left: 0.03,
        right: 0,
        bottom: 0
      },

      series: [{
        name: 'Requests',
        color: this.get('color'),
        data: data.sortBy('x')
      }]
    });

    detail = new Rickshaw.Graph.HoverDetail({
      graph: graph,

      xFormatter: function(x) {
        return moment(x, 'X').format('ddd, MMM Do');
      },

      yFormatter: function(y) {
        return y;
      }
    });

    xAxes = new Rickshaw.Graph.Axis.Time({
      graph: graph
    });

    yAxes = new Rickshaw.Graph.Axis.Y({
      graph: graph,
      tickFormat: Rickshaw.Fixtures.Number.formatKMBT
    });

    graph.render();
  },

  didInsertElement: function() {
    if (!this.get('width')) {
      this.set('width', this.$().parent().width());
    }

    this.draw();
  }
});
