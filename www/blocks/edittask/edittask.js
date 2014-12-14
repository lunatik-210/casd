
define(
    [
        //System includes
        "angular",
        "bootstrapUi"
    ],

    function (angular)
    {
        return angular.module
        (
            "uiEditTaskModule",
            [
                "ui.bootstrap"
            ]
        )

        .controller
        (
            'EditTaskModalCtr',
            [
                "$scope",
                "$modalInstance",
                "form",
                function ($scope, $modalInstance, form)
                {
                    $scope.type_opt =
                        [
                            {
                                id: "Feature",
                                name: "Feature"
                            },
                            {
                                id: "Bug",
                                name: "Bug"
                            }
                        ];

                    $scope.priority_opt =
                        [
                            {
                                id: "High",
                                name: "High"
                            },
                            {
                                id: "Normal",
                                name: "Normal"
                            },
                            {
                                id: "Low",
                                name: "Low"
                            }
                        ];

                    $scope.position_opt =
                        [
                            {
                                id: "Backlog",
                                name: "Backlog"
                            },
                            {
                                id: "Process",
                                name: "Process"
                            },
                            {
                                id: "Done",
                                name: "Done"
                            },
                            {
                                id: "Testing",
                                name: "Testing"
                            },
                            {
                                id: "Canceled",
                                name: "Canceled"
                            }
                        ];

                    $scope.form = form;

                    $scope.save = function (form)
                    {
                        $modalInstance.close(form);
                    };

                    $scope.cancel = function ()
                    {
                        $modalInstance.dismiss('cancel');
                    };
                }
            ]
        )

        .controller
        (
            "EditTaskCtr",
            [
                "$scope",
                "$modal",
                function($scope, $modal)
                {
                    $scope.editTask = function (task, size)
                    {
                        var modalInstance = $modal.open
                        (
                            {
                                templateUrl: 'blocks/edittask/modal.html',
                                controller: 'EditTaskModalCtr',
                                size: size,
                                resolve:
                                {
                                    form: function()
                                    {
                                        return {
                                            title: task.title,
                                            description: task.description,
                                            priority: task.priority,
                                            position: task.position,
                                            type: task.type,
                                            points: parseInt(task.points, 10)
                                        };
                                    }
                                }
                            }
                        );

                        modalInstance.result.then
                        (
                            function (form)
                            {
                                $scope.$emit
                                (
                                    "edit_task",
                                    {
                                        form: form,
                                        task_id: task.id,
                                        sprint_id: task.sprint_id,
                                        project_id: task.project_id
                                    }
                                );
                            }
                        );
                    };
                }
            ]
        );
    }
);
