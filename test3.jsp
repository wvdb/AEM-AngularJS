<%@include file="/libs/foundation/global.jsp" %>

<%-- pick up the jquery plugin library --%> 

<cq:includeClientLib categories="apps.mywebsite.test3"/>

<script type="text/javascript">

      //=====================================================================
      //=====================================================================
	  // Global Vars 
      // ----------- 
      // var dataTable = DataTable API instance 
      //     (doc http://www.datatables.net/upgrade/1.10 and http://www.datatables.net/manual/api) 
      //=====================================================================
	  //=====================================================================

      var dataTable;

      //=====================================================================
      //=====================================================================
	  // Angular Logic
      //=====================================================================
	  //=====================================================================

      angular.module('HW', [])
          .controller('myController', ['$scope', '$http', function($scope, $http) {

          // store in Angular scope, the value of the JSP variable properties.jcrPath (being a property belonging to an AEM component)
          // ------------------------------------------------------------------------------------------------------------

          $scope.jcrPath = '${properties.jcrPath}' + '/';

          $scope.nodes = [];

          // actual getEntries function 
          // getEntries function does a HTTP GET request by using the $http service
          // the request is asynchronous 
          //  an anonymous CallBACK function with 4 arguments is passed to the success promise method 
          //  an anonymous CallBACK function with 4 arguments is passed to the error promise method 
          // ----------------------------

          $scope.getEntries = function () { 
              console.log ('start getEntries()'); 
              console.log ('getEntries() >>> jcrPath = ' + $scope.jcrPath); 

              var myXHRUrl = "<%= currentNode.getPath() %>" + ".jcr"; 
              console.log ('myXHRUrl = ' + myXHRUrl);

              $http({method: 'GET',
                     url: myXHRUrl,
                     params: {'jcrPath': $scope.jcrPath}
              }).success(function(data, status, headers, config) {
                  console.log ('getEntries() success - started'); 
                  console.log ('getEntries() success - data.length = ' + data.length); 

                  // data contains NodeId, ResourceType, ModificationDate but ModificationDate requires formatting (dd/mm/yyyy) 
                  // -----------------------

                  for	(index = 0; index < data.length; index++) {
                      // console.log ('getEntries() NodeId = ' + data[index].NodeId); 
                      // console.log ('getEntries() ResourceType = ' + data[index].ResourceType); 
                      // console.log ('getEntries() ModificationDate = ' + data[index].ModificationDate); 

                      var formattedDate = ''; 
                      if (data[index].ModificationDate != null) { 
                        var dateString = data[index].ModificationDate;

                        // convert 2014-06-13T11:58:35.675+02:00 to 13/06/2014 
                        var dateParts = dateString.substr(0,10).split('-');
                        formattedDate = dateParts[2] + '/' + dateParts[1] + '/' + dateParts[0];
                        // console.log ('getEntries() Formatted ModificationDate = ' + formattedDate); 

                        data[index].ModificationDate = formattedDate;
                      }    
                  }

                  // persist actual data in angularjs scope !!!
                  // ------------------------------------------ 
                  
                  $scope.nodes = data;

                  // call javascript function to build the dataTable 
                  // -----------------------------------------------
                  setupDataTable($scope.nodes); 

                  console.log ('getEntries() success - exiting - # nodes = ' + $scope.nodes.length); 
              }).error(function(data, status, headers, config) {
                          console.log ('getEntries() error, status = ' + status); 
                          alert("error = " + status);
              }); // end $http service
          };        

          // watch function with 2 arguments
          //    -- value to be watched (jcrPath) 
          //    -- listener function with new and old value 
          // ----------------------------

          $scope.$watch('jcrPath',
              function(newValue, oldValue) {
                  console.log ('listener() started'); 

                  // only trigger the getEntries function when newValue finishes with a slash 
                  var stringLength = newValue.length; 

                  if (newValue.charAt(stringLength - 1) == '/') { 
                      // don't forget the getEntries method triggers an ASYNC HTTP request so don't expect the model to be accurate after the invocation of the method 
                      $scope.getEntries(); 
                  }     
              }
          );

      }]);

      //=====================================================================
      //=====================================================================
	  // JS Logic
      //=====================================================================
	  //=====================================================================

      function setupDataTable(nodes) {
          console.log ('start setupDataTable()'); 

          if (! dataTable) { 
            console.log ('dataTable undefined ==> returning'); 
            return;
          }    

          console.log ('continue setupDataTable() -- adding array of nodes to dataTable, size of nodes = ' + nodes.length); 

          dataTable.clear().rows.add(nodes).draw();

          console.log ('exiting setupDataTable()'); 
      }

      //=====================================================================
      //=====================================================================
	  // JQuery Logic -- initialization of global var dataTable with configuration based on columns 
      //=====================================================================
	  //=====================================================================

      jQuery(function () {
          console.log ('start JQuery function()'); 
          dataTable = jQuery('#myTable1').DataTable({
            columns: [
              { data: "NodeId"				, "width": "50%" , "searchable": true  , "orderable": true,  "title": "Node Id", "className" : "order-column"},
              { data: "ResourceType" 		, "width": "30%" , "searchable": true  , "orderable": true,  "title": "Resource Type"},
              { data: "ModificationDate"	, "width": "20%" , "searchable": false , "orderable": false, "title": "Modification Date", "className" : "dt-body-center"}
            ]
          });
      });

</script> 

<!-- =====================================================================
    // HTML
    // --------------------
    //
     ===================================================================== -->

<!-- useful for troubleshooting : the properties.jcrPath JSP variable should contain the JCR path to be queried -->
<!-- properties.jcrPath: ${properties.jcrPath} </br> -->

<div id='myDivId' ng-app='HW' ng-controller="myController" >
    JCR Path: <input type="text" style="size: 50;width: 600px;" id="jcrPath" name="jcrPath" ng-model="jcrPath"/>  <br>
    JCR Path entered: {{jcrPath | limitTo:100 | lowercase}} </p>

    <table class="display" width="100%" id="myTable1">
    </table>

</div>
