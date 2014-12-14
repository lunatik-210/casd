
define(
    [
        //System includes
        "angular",

        //Custom includes
        "blocks/registration/registration",
        "pages/js/restapi"
    ],

    function(angular)
    {

        return angular.module
        (
            "LoginModule",
            [
                "RestApiModule",
                "uiRegistrationModule"
            ]
        )

        .controller
        (
            "LoginCtr",
            [
                "$scope",
                "$log",
                "restapi",
                "$state",
                function($scope, $log, restapi, $state)
                {
                    $scope.restapi = restapi;

                    $scope.login = function(form)
                    {
                        restapi.login(form.email, form.password).then
                        (
                            function ()
                            {
                                $state.go("projects");
                            }
                        )
                    };

                    $scope.logout = function()
                    {
                        restapi.logout();
                    };
                }
            ]
        );
    }
);
