<script>
    $(document).ready(function() {
        var data_get_map = {'frm': "/api/adguardhome/general/get"};
        mapDataToFormUI(data_get_map).done(function() {
            formatTokenizersUI();
            $('.selectpicker').selectpicker('refresh');
            updateServiceControlUI('adguardhome');
        });

        var formIds = [
            'frm-GeneralSettings',
            'frm-DnsSettings',
            'frm-EncryptionSettings',
            'frm-QueryLogSettings',
            'frm-CacheSettings',
            'frm-AccessSettings'
        ];

        function saveAllForms() {
            var dfObj = $.Deferred();
            var idx = 0;
            function saveNext() {
                if (idx >= formIds.length) {
                    dfObj.resolve();
                    return;
                }
                saveFormToEndpoint("/api/adguardhome/general/set", formIds[idx], function() {
                    idx++;
                    saveNext();
                }, true, dfObj.reject);
            }
            saveNext();
            return dfObj;
        }

        $("#reconfigureAct").SimpleActionButton({
            onPreAction: function() {
                return saveAllForms();
            },
            onAction: function(data, status) {
                if (status === "success" && data.status === 'ok') {
                    ajaxCall("/api/adguardhome/service/reconfigure", {}, function(reconfigData, reconfigStatus) {
                        if (reconfigStatus === "success" && reconfigData.status === 'ok') {
                            updateServiceControlUI('adguardhome');
                        }
                    });
                }
            }
        });

        updateServiceControlUI('adguardhome');
    });
</script>

<ul class="nav nav-tabs" data-tabs="tabs" id="maintabs">
    <li class="active"><a data-toggle="tab" href="#general">{{ lang._('General') }}</a></li>
    <li><a data-toggle="tab" href="#encryption">{{ lang._('Encryption') }}</a></li>
    <li><a data-toggle="tab" href="#dns">{{ lang._('DNS') }}</a></li>
    <li><a data-toggle="tab" href="#cache">{{ lang._('Cache') }}</a></li>
    <li><a data-toggle="tab" href="#access">{{ lang._('Access') }}</a></li>
    <li><a data-toggle="tab" href="#querylog">{{ lang._('Query Log') }}</a></li>
</ul>

<div class="tab-content content-box">
    <div id="general" class="tab-pane fade in active">
        {{ partial("layout_partials/base_form", ['fields': generalForm, 'id': 'frm-GeneralSettings']) }}
    </div>
    <div id="encryption" class="tab-pane fade in">
        {{ partial("layout_partials/base_form", ['fields': encryptionForm, 'id': 'frm-EncryptionSettings']) }}
    </div>
    <div id="dns" class="tab-pane fade in">
        {{ partial("layout_partials/base_form", ['fields': dnsForm, 'id': 'frm-DnsSettings']) }}
    </div>
    <div id="cache" class="tab-pane fade in">
        {{ partial("layout_partials/base_form", ['fields': cacheForm, 'id': 'frm-CacheSettings']) }}
    </div>
    <div id="access" class="tab-pane fade in">
        {{ partial("layout_partials/base_form", ['fields': accessForm, 'id': 'frm-AccessSettings']) }}
    </div>
    <div id="querylog" class="tab-pane fade in">
        {{ partial("layout_partials/base_form", ['fields': querylogForm, 'id': 'frm-QueryLogSettings']) }}
    </div>
</div>

<section class="page-content-main">
    <div class="content-box">
        <div class="col-md-12">
            <br/>
            <button class="btn btn-primary" id="reconfigureAct"
                    data-endpoint="/api/adguardhome/service/reconfigure"
                    data-label="{{ lang._('Apply') }}"
                    type="button">
                {{ lang._('Apply') }}
            </button>
            <br/><br/>
        </div>
    </div>
</section>
