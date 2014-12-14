
define(
    [
        //System includes
        "angular",
        "angularUIRoute",
        "angularAnimate",
        "bootstrapUi",

        //Custom includes
        "blocks/navbar/navbar",
        "pages/js/projects",
        "pages/js/project",
        "pages/js/login",
        "pages/js/user",
        "pages/js/restapi",
        "pages/js/alertservice",
        "pages/js/sprints",
        "pages/js/tasks"
    ],

    function(angular)
    {
        return angular.module
        (
            "CasdModule",
            [
                'ui.router',
                "uiNavbarModule",
                "LoginModule",
                "ProjectsModule",
                "ProjectModule",
                "UserModule",
                "ngAnimate",
                "AlertServiceModule",
                "ui.bootstrap.alert",
                "SprintsModule",
                "TasksModule"
            ]
        )

        .config
        (
            [
                "$stateProvider",
                "$urlRouterProvider",
                function($stateProvider, $urlRouterProvider)
                {
                    $urlRouterProvider.otherwise("/projects");

                    $stateProvider
                    .state
                    (
                        "projects",
                        {
                            url: "/projects",
                            templateUrl: "pages/html/projects.html",
                            controller: "ProjectsCtr",
                            resolve:
                            {
                                projects:
                                [
                                    "ProjectsProvider",
                                    function (ProjectsProvider)
                                    {
                                        return ProjectsProvider.resolver();
                                    }
                                ]
                            }
                        }
                    )

                    .state
                    (
                        "project",
                        {
                            url: "/projects/:id",
                            templateUrl: "pages/html/project.html",
                            controller: "ProjectCtr",
                            resolve:
                            {
                                project:
                                [
                                    "$stateParams",
                                    "ProjectProvider",
                                    function($stateParams, ProjectProvider)
                                    {
                                        return ProjectProvider.resolver($stateParams.id);
                                    }
                                ]
                            }
                        }
                    )

                    .state
                    (
                        "project.tasks",
                        {
                            url: "/tasks",
                            templateUrl: "pages/html/project/tasks.html",
                            controller: "ProjectTasksCtr",
                            resolve:
                            {
                                tasks:
                                [
                                    "$stateParams",
                                    "ProjectTasksProvider",
                                    function($stateParams, ProjectTasksProvider)
                                    {
                                        return ProjectTasksProvider.resolver($stateParams.id);
                                    }
                                ]
                            }
                        }
                    )
                        .state
                    (
                        "project.report",
                        {
                            url: "/report",
                            templateUrl: "pages/html/project/report.html",
                            controller: "ProjectReportCtr",
                            resolve:
                            {
                                report:
                                    [
                                        "$stateParams",
                                        "ProjectReportProvider",
                                        function($stateParams, ProjectReportProvider)
                                        {
                                            return ProjectReportProvider.resolver($stateParams.id);
                                        }
                                    ]
                            }
                        }
                    )
                    .state
                    (
                        "project.sprints",
                        {
                            url: "/sprints",
                            templateUrl: "pages/html/project/sprints.html",
                            controller: "ProjectSprintsCtr",
                            resolve:
                            {
                                sprints:
                                [
                                    "$stateParams",
                                    "ProjectSprintsProvider",
                                    function($stateParams, ProjectSprintsProvider)
                                    {
                                        return ProjectSprintsProvider.resolver($stateParams.id);
                                    }
                                ]
                            }
                        }
                    )

                    .state
                    (
                        "project.sprint",
                        {
                            url: "/sprints/:sprint_id",
                            templateUrl: "pages/html/project/sprint.html",
                            controller: "ProjectSprintCtr",
                            resolve:
                            {
                                data:
                                [
                                    "$stateParams",
                                    "ProjectSprintProvider",
                                    function($stateParams, ProjectSprintProvider)
                                    {
                                        return ProjectSprintProvider.resolver($stateParams.id, $stateParams.sprint_id);
                                    }
                                ]
                            }
                        }
                    )

                    .state
                    (
                        "project.users",
                        {
                            url: "/users",
                            templateUrl: "pages/html/project/users.html",
                            controller: "ProjectUsersCtr",
                            resolve:
                            {
                                all_users:
                                [
                                    "AllUsersProvider",
                                    function (AllUsersProvider)
                                    {
                                        return AllUsersProvider.resolver();
                                    }
                                ],

                                collaborators:
                                [
                                    "ProjectCollaboratorsProvider",
                                    "$stateParams",
                                    function (ProjectCollaboratorsProvider, $stateParams)
                                    {
                                        return ProjectCollaboratorsProvider.resolver($stateParams.id);
                                    }
                                ]
                            }
                        }
                    )

                    .state
                    (
                        "user",
                        {
                            url: "/user",
                            templateUrl: "pages/html/user.html",
                            controller: "UserCtr",
                            resolve:
                            {
                                user:
                                [
                                    "UserProvider",
                                    function (UserProvider)
                                    {
                                        return UserProvider.resolver();
                                    }
                                ]
                            }
                        }
                    )

                    .state
                    (
                        "task",
                        {
                            url: "/task",
                            templateUrl: "pages/html/task.html"
                        }
                    )

                    .state
                    (
                        "login",
                        {
                            url: "/login",
                            templateUrl: "pages/html/login.html",
                            controller: "LoginCtr"
                        }
                    )

                    .state
                    (
                        "sprints",
                        {
                            url: "/sprints",
                            templateUrl: "pages/html/sprints.html",
                            controller: "SprintsCtr",
                            resolve:
                            {
                                sprints:
                                [
                                    "SprintsProvider",
                                    function (SprintsProvider)
                                    {
                                        return SprintsProvider.resolver();
                                    }
                                ],
                                projects:
                                [
                                    "ProjectsProvider",
                                    function (ProjectsProvider)
                                    {
                                        return ProjectsProvider.resolver();
                                    }
                                ]
                            }
                        }
                    )

                    .state
                    (
                        "tasks",
                        {
                            url: "/tasks",
                            templateUrl: "pages/html/tasks.html",
                            controller: "TasksCtr",
                            resolve:
                            {
                                tasks:
                                [
                                    "TasksProvider",
                                    function (TasksProvider)
                                    {
                                        return TasksProvider.resolver();
                                    }
                                ],
                                projects:
                                [
                                    "ProjectsProvider",
                                    function (ProjectsProvider)
                                    {
                                        return ProjectsProvider.resolver();
                                    }
                                ]
                            }
                        }
                    );
                }
            ]
        )

        .controller
        (
            "CasdCtr",
            [
                "$scope",
                "restapi",
                "$state",
                "alertservice",
                "$rootScope",
                function($scope, restapi, $state, alertservice)
                {
                    $scope.$on
                    (
                        'event:loginRequired',
                        function()
                        {
                            if(restapi.is_logged())
                            {
                                alertservice.add(undefined,  "You're not allowed to perform that operation!", 3000);
                            }
                            else
                            {
                                alertservice.add(undefined,  "Please, login into the system!", 3000);
                                $state.go("login");
                            }
                        }
                    );

                    $scope.closeAlert = function (index)
                    {
                        alertservice.closeAlert(index);
                    }
                }
            ]
        );
    }
);
