import Serializer from 'manager/serializers/application';

export default Serializer.extend({
  serializeIntoHash: function(hash, type, record, options) {
    hash.account = this.serialize(record, options);
  }
});
