define(
    [
        //System includes
        "angular",
        "angularFilters",

        //Custom includes
        "pages/js/restapi",
        "pages/js/helper"
    ],
    function(angular)
    {
        return angular.module
        (
            "SprintsModule",
            [
                "RestApiModule",
                "angular.filter",
                "HelperModule"
            ]
        )
        .controller
        (
            "SprintsCtr",
            [
                "$scope",
                "sprints",
                "projects",
                "$state",
                "sprintHelper",
                function($scope, sprints, projects, $state, sprintHelper)
                {
                    $scope.sprints = sprints;
                    $scope.projects = projects;
                    $scope.state = $state;
                    $scope.get_sprint_style = sprintHelper.get_style;

                    $scope.go = function(project_id, sprint_id)
                    {
                        $state.go("project.sprint", {id:project_id, sprint_id:sprint_id} );
                    }
                }
            ]
        )

        .factory
        (
            'SprintsProvider',
            [
                "restapi",
                function(restapi)
                {
                    var module = {};
                    module.resolver = function()
                    {
                        return restapi.sprints();
                    };
                    return module;
                }
            ]
        )
    }
);