
// Use Parse.Cloud.define to define as many cloud functions as you want.

Parse.Cloud.beforeSave("Party", function(request, response) {
                       Parse.Cloud.useMasterKey();                      
                       var query = new Parse.Query("Party");
                       query.equalTo("fbEventId",request.object.get("fbEventId"));
                       query.first({
                                   success: function(object) {
                                   if (object) {
                                   response.error("This party already exists!");
                                   } else {
                                   response.success();
                                   }
                                   },
                                   error: function(error) {
                                   response.error("Could not validate uniqueness for this party!");
                                   }
                           });
                       });


Parse.Cloud.afterSave("Activity", function(request) {
                      Parse.Cloud.useMasterKey();
                      
                      var activityType = request.object.get("type");
                      
                      if (activityType = "upvote")
                      {
                      
                      var query = new Parse.Query("Party");
                      query.get(request.object.get("party").id, {
                                success: function(party) {
                                party.increment("upvoteCount");
                                party.save(null,{
                                           success: function(object) {},
                                           error: function(object, error)
                                           {
                                           console.log("Failed to save objectId: " + object.id + " - " + "Error: " + error.code + " - " + error.status);
                                           }
                                           });
                                },
                                error: function(object, error) {
                                console.error("Error getting Party: "  + error.code + " : " + error.message);
                                }
                                });
                      
                      } else if (activityType = "comment")
                      {
                      var query = new Parse.query("Party");
                      query.get(request.object.get("party").id, {
                                success: function(party) {
                                party.increment("commentCount");
                                party.save(null,{
                                           success: function(object) {},
                                           error: function(object, error)
                                           {
                                           console.log("Failed to save objectId: " + object.id + " - " + "Error: " + error.code + " - " + error.status);
                                           }
                                           });
                                },
                                error: function(object, error) {
                                console.error("Error getting party: "  + error.code + " : " + error.message);
                                }
                                });
                      }
                      });

Parse.Cloud.afterDelete("Activity", function(request) {
                        Parse.Cloud.useMasterKey();
                        
                        var activityType = request.object.get("type");
                        
                        if (activityType = "upvote")
                        {
                        
                        var query = new Parse.Query("Party");
                        query.get(request.object.get("party").id, {
                                  success: function(party) {
                                  party.increment("upvoteCount",-1);
                                  party.save(null,{
                                             success: function(object) {},
                                             error: function(object, error)
                                             {
                                             console.log("Failed to save objectId: " + object.id + " - " + "Error: " + error.code + " - " + error.status);
                                             }
                                             });
                                  },
                                  error: function(object, error) {
                                  console.error("Error getting Party: "  + error.code + " : " + error.message);
                                  }
                                  });
                        
                        } else if (activityType = "comment")
                        {
                        var query = new Parse.query("Party");
                        query.get(request.object.get("party").id, {
                                  success: function(party) {
                                  party.increment("commentCount",-1);
                                  party.save(null,{
                                             success: function(object) {},
                                             error: function(object, error)
                                             {
                                             console.log("Failed to save objectId: " + object.id + " - " + "Error: " + error.code + " - " + error.status);
                                             }
                                             });
                                  },
                                  error: function(object, error) {
                                  console.error("Error getting party: "  + error.code + " : " + error.message);
                                  }
                                  });
                        }
                        });