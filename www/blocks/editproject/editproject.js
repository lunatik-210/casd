
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
            "uiEditProjectModule",
            [
                "ui.bootstrap"
            ]
        )

        .controller
        (
            'EditProjectModalCtr',
            [
                "$scope",
                "$modalInstance",
                "form",
                function ($scope, $modalInstance, form)
                {
                    $scope.options = [
                        {
                            id: "Active",
                            name: "Active"
                        },
                        {
                            id: "Complete",
                            name: "Complete"
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
            "EditProjectCtr",
            [
                "$scope",
                "$modal",
                function($scope, $modal)
                {
                    $scope.editProject = function (project, size)
                    {
                        var modalInstance = $modal.open
                        (
                            {
                                templateUrl: 'blocks/editproject/modal.html',
                                controller: 'EditProjectModalCtr',
                                resolve:
                                {
                                    form: function()
                                    {
                                        return {
                                            name: project.name,
                                            status: project.status,
                                            description: project.description,
                                            max_points_per_sprint: parseInt(project.max_points_per_sprint, 10)
                                        };
                                    }
                                },
                                size: size
                            }
                        );

                        modalInstance.result.then
                        (
                            function (form)
                            {
                                $scope.$emit("edit_project", {form: form, project_id: project.id});
                            }
                        );
                    };
                }
            ]
        );
    }
);
