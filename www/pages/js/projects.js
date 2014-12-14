
define(
    [
        //System includes
        "angular",
        "angularFilters",

        //Custom includes
        "blocks/createproject/createproject",
        "blocks/editproject/editproject",
        "pages/js/restapi",
        "pages/js/helper"
    ],

    function(angular)
    {
        return angular.module
        (
            "ProjectsModule",
            [
                "RestApiModule",
                "uiRegistrationModule",
                "uiCreateProjectModule",
                "uiEditProjectModule",
                "angular.filter",
                "HelperModule"
            ]
        )

        .controller
        (
            "ProjectsCtr",
            [
                "$scope",
                "$log",
                "restapi",
                "projects",
                "$state",
                "projectHelper",
                function($scope, $log, restapi, projects, $state, projectHelper)
                {
                    function update_projects()
                    {
                        return restapi.projects().then
                        (
                            function(data)
                            {
                                $scope.projects = data;
                            }
                        )
                    }

                    $scope.projects = projects;
                    $scope.get_project_style = projectHelper.get_style;

                    $scope.remove = function(project)
                    {
                        restapi.remove_project(project.id).then(update_projects);
                    };

                    $scope.go = function (project)
                    {
                        $state.go("project.tasks", {id:project.id});
                    };

                    $scope.$on
                    (
                        "create_project",
                        function(event, data)
                        {
                            event.stopPropagation();
                            restapi.create_project(data.project_name, data.description, data.max_points_per_sprint).then(update_projects);
                        }
                    );

                    $scope.$on
                    (
                        "edit_project",
                        function(event, data)
                        {
                            event.stopPropagation();
                            restapi.edit_project(data.form, data.project_id).then(update_projects);
                        }
                    );
                }
            ]
        )

        .factory
        (
            'ProjectsProvider',
            [
                "restapi",
                function(restapi)
                {
                    var module = {};
                    module.resolver = function()
                    {
                        return restapi.projects();
                    };
                    return module;
                }
            ]
        );
    }
);
