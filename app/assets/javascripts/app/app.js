//= require ./lib/URI
//= require_tree ./templates

App = Ember.Application.create();

App.Page = Em.Object.extend({
  title: null,
  description: null,
  url: null,
  thumbnail: null,
  link: function() {
    return '/' + this.get('url');
  }.property('url')
});

App.pagesController = Em.ArrayProxy.create({
  content: [],
  load: function() {
    var self = this;
    $.ajax({
      url: '/',
      dataType: 'json',
      success: function(response){
        self.set('content', []);
        response.pages.forEach(function(page) {
          self.pushObject(App.Page.create(page));
        });
      }
    });
  },
  remove: function(page) {
    var self = this;
    $.ajax({
      type: 'DELETE',
      url: '/' + page.id,
      dataType: 'json',
      success: function(response){
        self.removeObject(page);
      }
    });
  },
  add: function(url) {
    var self = this;
    $.ajax({
      url: '/' + url,
      dataType: 'json',
      success: function(response){
          self.unshiftObject(App.Page.create(response));
      }
    });
  }
});

App.AddPageView = Em.TextField.extend({
  insertNewline: function() {
    var url = this.get('value');
    if (url) {
      App.pagesController.add(url);
      this.set('value', '');
    }
  }
});

App.PagesView = Ember.View.create({
  templateName: 'app/pages',
  destroyPage: function(page) {
    App.pagesController.remove(page);
  }
});

// Init
$.ajaxSetup({cache: false}); // Fixes the cache issue with back button
App.pagesController.load();
App.PagesView.appendTo('#pages');