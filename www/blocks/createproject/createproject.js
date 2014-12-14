
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
            "uiCreateProjectModule",
            [
                "ui.bootstrap"
            ]
        )

        .controller
        (
            'CreateProjectModalCtr',
            [
                "$scope",
                "$modalInstance",
                function ($scope, $modalInstance)
                {
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
            "CreateProjectCtr",
            [
                "$scope",
                "$modal",
                function($scope, $modal)
                {
                    $scope.createProject = function (size)
                    {
                        var modalInstance = $modal.open
                        (
                            {
                                templateUrl: 'blocks/createproject/modal.html',
                                controller: 'CreateProjectModalCtr',
                                size: size
                            }
                        );

                        modalInstance.result.then
                        (
                            function (form)
                            {
                                $scope.$emit("create_project", form);
                            }
                        );
                    };
                }
            ]
        );
    }
);
