import Em from 'ember';

// paddedCycleRequests: function() {
//   var ret     = [];
//   var scores  = {};
//   var current = moment().startOf('month');
//   var last    = moment().endOf('month');
//   var isoDate;

//   this.get('cycleRequests').forEach(function(pair) {
//     scores[pair[0]] = pair[1];
//   });

//   while (!current.isAfter(last, 'day')) {
//     isoDate = current.format('YYYY-MM-DD');
//     ret.push([isoDate, scores[isoDate] || 0]);
//     current.add(1, 'day');
//   }

//   return ret;
// }.property('cycleRequests')

export default Em.ObjectController.extend({
});
