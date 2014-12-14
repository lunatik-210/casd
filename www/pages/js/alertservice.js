/**
 * Created by andrew on 24.05.14.
 */

define(
    [
        //System includes
        "angular"
    ],

    function (angular) {
        return angular.module("AlertServiceModule", [])

        .factory
        (
            "alertservice",
            [
                "$timeout",
                "$rootScope",
                function($timeout, $rootScope)
                {
                    $rootScope.alerts = [];

                    var alertService = {
                        add: function(type, msg, timeout) {
                            $rootScope.alerts.push({
                                type: type,
                                msg: msg,
                                close: function() {
                                    return alertService.closeAlert(this);
                                }
                            });

                            if (timeout) {
                                $timeout(function(){
                                    alertService.closeAlert(this);
                                }, timeout);
                            }
                        },
                        closeAlert: function(alert) {
                            return this.closeAlertIdx($rootScope.alerts.indexOf(alert));
                        },
                        closeAlertIdx: function(index) {
                            return $rootScope.alerts.splice(index, 1);
                        }
                    };

                    return alertService;
                }
            ]
        );
    }
);
