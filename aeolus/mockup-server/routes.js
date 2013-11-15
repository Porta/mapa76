
module.exports = function(){

  app.get('/', function(req, res){
    res.send('Mockup Server');
  });

  app.get('/api/v1/documents', function(req, res){
    res.send(require('./data/documents'));
  });

  app.del('/api/v1/documents/:id', function(req, res){
    res.send(204);
  });

  app.get('/api/v1/documents/status', function(req, res){
    res.send(require('./data/status'));
  });

};