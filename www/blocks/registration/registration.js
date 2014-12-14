
define(
    [
        //System includes
        "angular",
        "bootstrapUi",
        "angularUtils",

        //Custom includes
        "pages/js/restapi"
    ],

    function (angular)
    {
        return angular.module
        (
            "uiRegistrationModule",
            [
                "RestApiModule",
                "ui.bootstrap",
                "ui.validate"
            ]
        )

        .controller
        (
            'RegistrationModalCtr',
            [
                "$scope",
                "$modalInstance",
                function ($scope, $modalInstance)
                {
                    $scope.ok = function (form)
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
            "RegistrationCtr",
            [
                "$scope",
                "$modal",
                "$log",
                "restapi",
                "$state",
                function($scope, $modal, $log, restapi, $state)
                {
                    $scope.register = function (size)
                    {
                        var modalInstance = $modal.open
                        (
                            {
                                templateUrl: 'blocks/registration/modal.html',
                                controller: 'RegistrationModalCtr',
                                size: size
                            }
                        );

                        modalInstance.result.then
                        (
                            function (form)
                            {
                                $log.info(form);
                                restapi.register(form.name, form.email, form.password)
                                .then
                                (
                                    function()
                                    {
                                        restapi.login(form.email, form.password)
                                        .then
                                        (
                                            function()
                                            {
                                                $state.go("projects");
                                            }
                                        )
                                    }
                                )
                            }
                        );
                    };
                }
            ]
        );
    }
);
