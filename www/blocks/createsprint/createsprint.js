
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
            "uiCreateSprintModule",
            [
                "ui.bootstrap"
            ]
        )

        .controller
        (
            'CreateSprintModalCtr',
            [
                "$scope",
                "$modalInstance",
                function ($scope, $modalInstance)
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

                    $scope.form =
                    {
                        status: "Backlog"
                    };

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
            "CreateSprintCtr",
            [
                "$scope",
                "$modal",
                function($scope, $modal)
                {
                    $scope.createSprint = function (size)
                    {
                        var modalInstance = $modal.open
                        (
                            {
                                templateUrl: 'blocks/createsprint/modal.html',
                                controller: 'CreateSprintModalCtr',
                                size: size
                            }
                        );

                        modalInstance.result.then
                        (
                            function (form)
                            {
                                $scope.$emit("create_sprint", form);
                            }
                        );
                    };
                }
            ]
        );
    }
);
