
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
            "uiEditSprintModule",
            [
                "ui.bootstrap"
            ]
        )

        .controller
        (
            'EditSprintModalCtr',
            [
                "$scope",
                "$modalInstance",
                "form",
                function ($scope, $modalInstance, form)
                {
                    $scope.options =
                        [
                            {
                                id: "Backlog",
                                name: "Backlog"
                            },
                            {
                                id: "Started",
                                name: "Started"
                            },
                            {
                                id: "Complete",
                                name: "Complete"
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
            "EditSprintCtr",
            [
                "$scope",
                "$modal",
                function($scope, $modal)
                {
                    $scope.editSprint = function (sprint, size)
                    {
                        var modalInstance = $modal.open
                        (
                            {
                                templateUrl: 'blocks/editsprint/modal.html',
                                controller: 'EditSprintModalCtr',
                                size: size,
                                resolve:
                                {
                                    form: function()
                                    {
                                        return {
                                            status: sprint.status,
                                            duration: parseInt(sprint.duration, 10)
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
                                    "edit_sprint",
                                    {
                                        form: form,
                                        sprint_id: sprint.id,
                                        project_id: sprint.project_id
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
