/**
 * Created by andrew on 24.05.14.
 */

define(
    [
        //System includes
        "angular",
        "storeJson2",

        //Custom includes
        "pages/js/alertservice"
    ],

    function (angular, store) {
        return angular.module
        ("RestApiModule",
            [
                "AlertServiceModule"
            ]
        )


        .config
        (
            [
                "$httpProvider",
                function($httpProvider)
                {
                    $httpProvider.responseInterceptors.push("errorHttpInterceptor");
                }
            ]
        )

        .factory
        (
            "restapi",
            [
                "$http",
                "$log",
                "alertservice",
                function($http, $log, alertservice)
                {

                    //////////////////////////////////////////////////////////////
                    ////////////////////// THIS
                    var module = {};

                    //////////////////////////////////////////////////////////////
                    ////////////////////// PUBLIC VARIABLES


                    //////////////////////////////////////////////////////////////
                    ////////////////////// PUBLIC METHODS

                    module.change = function(name, email, password, id)
                    {
                        var data =
                        {
                            user_name: name,
                            email: email,
                            password: password
                        };

                        return $http.post('/api/users/'+id, data);
                    };

                    module.delete_user = function(id)
                    {
                        return $http.delete('/api/users/'+id);
                    };

                    module.user = function ()
                    {
                        return store.get("user");
                    };

                    module.is_logged = function ()
                    {
                        return !(module.user()===undefined);
                    };

                    module.login = function(email, password)
                    {
                        var data = {
                            email: email,
                            password: password
                        };

                        return $http.post('/api/sessions', data)
                        .success
                        (
                            function()
                            {
                                store.set("user", data.email);
                                alertservice.add("success", "You are successfully logged!", 2000);
                            }
                        )
                        .error
                        (
                            function(data, status)
                            {
                                alertservice.add("danger", "Login failed: " + data.Message + "!", 2000);
                            }
                        );
                    };

                    module.logout = function()
                    {
                        $http.delete('/api/sessions').then
                        (
                            function()
                            {
                                store.remove("user");
                                alertservice.add("success", "You are successfully logged out!", 2000);
                            }
                        )
                    };

                    module.register = function(name, email, password)
                    {
                        var data =
                        {
                            user_name: name,
                            email: email,
                            password: password
                        };

                        return $http.post('/api/users', data);
                    };

                    module.projects = function()
                    {
                        return $http.get('/api/projects')
                        .then
                        (
                            function(data)
                            {
                                return data.data;
                            },
                            function(data)
                            {
                                $log.info("error");
                                $log.info(data);
                            }
                        )
                    };

                    module.project = function(project_id)
                    {
                        return $http.get('/api/projects/'+project_id)
                        .then
                        (
                            function(data)
                            {
                                return data.data;
                            },
                            function(data)
                            {
                                $log.info("error");
                                $log.info(data);
                            }
                        )
                    };

                    module.remove_project = function(id)
                    {
                        return $http.delete('/api/projects/' + id);
                    };

                    module.current_user = function()
                    {
                        return $http.get('/api/user')
                        .then
                        (
                            function(data)
                            {
                                return data.data;
                            },
                            function(data)
                            {
                                $log.debug("error");
                                $log.debug(data);
                            }
                        )
                    };

                    module.create_project = function(name, description, max_points_per_sprint)
                    {
                        var request =
                        {
                            name: name,
                            status: "Active",
                            description: description,
                            max_points_per_sprint: max_points_per_sprint.toString()
                        };

                        return $http.post("/api/projects", request).then
                        (
                            function(data)
                            {
                                alertservice.add("success", "You've successfully created new project!", 2000);
                                return data.data;
                            },
                            function(data)
                            {
                                alertservice.add("danger", "Sorry, please try again!", 2000);
                                $log.info("error");
                                $log.info(data);
                            }
                        );
                    };

                    module.edit_project = function (form, project_id)
                    {
                        var request =
                        {
                            name: form.name,
                            status: form.status,
                            description: form.description,
                            max_points_per_sprint: form.max_points_per_sprint.toString()
                        };

                        return $http.post("/api/projects/"+project_id, request);
                    };

                    module.create_task = function (form, project_id)
                    {
                        var request =
                        {
                            title: form.title,
                            description: form.description,
                            priority: form.priority,
                            position: form.position,
                            points: form.points.toString(),
                            type: form.type
                        };

                        if(form.super_task_id)
                        {
                            request.super_task_id = form.super_task_id;
                        }

                        return $http.post("/api/projects/"+project_id+"/tasks", request)
                        .then
                        (
                            function(data)
                            {
                                alertservice.add("success", "You've successfully add new task!", 2000);
                                return data.data;
                            },
                            function(data)
                            {
                                alertservice.add("danger", "Sorry, please try again!", 2000);
                                $log.info("error");
                                $log.info(data);
                            }
                        );
                    };

                    module.create_sub_task = function (form, project_id, super_task_id)
                    {
                        var request =
                        {
                            title: form.title,
                            description: form.description,
                            priority: form.priority,
                            position: form.position,
                            points: form.points.toString(),
                            type: form.type,
                            project_id: project_id
                        };

                        return $http.post("/api" + "/tasks/" + super_task_id + "/subtasks", request)
                        .then
                        (
                            function(data)
                            {
                                alertservice.add("success", "You've successfully add new sub task!", 2000);
                                return data.data;
                            },
                            function(data)
                            {
                                alertservice.add("danger", "Sorry, please try again!", 2000);
                                $log.info("error");
                                $log.info(data);
                            }
                        );
                    };

                    module.sub_tasks = function(super_task_id)
                    {
                        return $http.get("/api" + "/tasks/" + super_task_id + "/subtasks")
                        .then
                        (
                            function(data)
                            {
                                return data.data;
                            },
                            function(data)
                            {
                                $log.info("error");
                                $log.info(data);
                            }
                        );
                    };

                    module.all_users = function ()
                    {
                        return $http.get("/api/users").then
                        (
                            function(data)
                            {
                                return data.data;
                            }
                        )
                    };

                    module.project_collaborators = function (project_id) {
                        return $http.get("/api/projects/" + project_id + "/collaborators")
                        .then
                        (
                            function(data)
                            {
                                return data.data;
                            }
                        )
                    };

                    module.add_project_collaborator = function (project_id, user_id) {
                        return $http.post("/api/projects/" + project_id + "/collaborators/" + user_id, {})
                        .then
                        (
                            function(data)
                            {
                                alertservice.add("success", "New collaborator was added successfully!", 2000);
                                return data.data;
                            },
                            function(data)
                            {
                                alertservice.add("danger", "Sorry, please try again!", 2000);
                                $log.info("error");
                                $log.info(data);
                            }
                        )
                    };

                    module.remove_project_collaborator = function (project_id, user_id) {
                        return $http.delete("/api/projects/" + project_id + "/collaborators/" + user_id);
                    };

                    module.create_sprint = function(form, project_id)
                    {
                        var request =
                        {
                            status: form.status,
                            duration: form.duration.toString()
                        };

                        return $http.post("/api/projects/" + project_id + "/sprints", request)
                        .then
                        (
                            function(data)
                            {
                                alertservice.add("success", "You've successfully created new sprint!", 2000);
                                return data.data;
                            },
                            function(data)
                            {
                                alertservice.add("danger", "Sorry, please try again!", 2000);
                                $log.info("error");
                                $log.info(data);
                            }
                        )
                    };

                    module.edit_sprint = function(form, project_id, sprint_id)
                    {
                        var request =
                        {
                            status: form.status,
                            duration: form.duration.toString()
                        };
                        return $http.post("/api/projects/" + project_id + "/sprints/" + sprint_id, request);
                    };

                    module.delete_task = function (project_id, sprint_id)
                    {
                        return $http.delete("/api/projects/" + project_id + "/sprints/" + sprint_id);
                    };

                    module.project_sprints = function(project_id)
                    {
                        return $http.get("/api/projects/" + project_id + "/sprints")
                        .then
                        (
                            function (data)
                            {
                                return data.data;
                            }
                        )
                    };

                    module.project_report = function(project_id)
                    {
                      return $http.get("/api/projects/" + project_id + "/reports")
                          .then
                      (
                          function(data)
                          {
                              return data.data;
                          }
                      )
                    };
                    module.sprints = function()
                    {
                        return $http.get("/api/sprints")
                        .then
                        (
                            function (data)
                            {
                                return data.data;
                            }
                        )
                    };

                    module.project_sprint = function(project_id, sprint_id)
                    {
                        return $http.get("/api/projects/" + project_id + "/sprints/" + sprint_id)
                        .then
                        (
                            function (data)
                            {
                                return data.data;
                            }
                        )
                    };

                    module.project_tasks = function(project_id)
                    {
                        return $http.get("/api/projects/" + project_id + "/tasks")
                        .then
                        (
                            function (data)
                            {
                                return data.data;
                            }
                        )
                    };

                    module.delete_project_task = function(project_id, task_id)
                    {
                        return $http.delete("/api/projects/" + project_id + "/tasks/" + task_id);
                    };

                    module.edit_project_task = function (form, project_id, sprint_id, task_id)
                    {
                        var request =
                        {
                            title: form.title,
                            description: form.description,
                            priority: form.priority,
                            position: form.position,
                            points: form.points.toString(),
                            type: form.type,
                            sprint_id: sprint_id
                        };

                        return $http.post("/api/projects/" + project_id + "/tasks/" + task_id, request);
                    };

                    module.tasks = function()
                    {
                        return $http.get("/api/tasks")
                        .then
                        (
                            function (data)
                            {
                                return data.data;
                            }
                        )
                    };

                    //////////////////////////////////////////////////////////////
                    ////////////////////// PRIVATE METHODS

                    return module;
                }
            ]
        )

        .factory
        (
            "errorHttpInterceptor",
            [
                "$q",
                "$rootScope",
                function($q, $rootScope)
                {
                    function onSuccess(response)
                    {
                        return response;
                    }

                    function onError(response)
                    {
                        if(response.status === 401)
                        {
                            $rootScope.$broadcast("event:loginRequired");
                        }
                        return $q.reject(response);
                    }

                    return function(promise)
                    {
                        return promise.then(onSuccess, onError);
                    };
                }
            ]
        );
    }
);
