<script>
    $(document).ready(function() {
        function formatNumber(n) {
            if (n === undefined || n === null) return '0';
            return n.toLocaleString();
        }

        function formatTime(seconds) {
            if (!seconds) return '0 ms';
            if (seconds < 0.001) return (seconds * 1000000).toFixed(0) + ' \u00b5s';
            if (seconds < 1) return (seconds * 1000).toFixed(1) + ' ms';
            return seconds.toFixed(2) + ' s';
        }

        function buildTopTable(selector, items) {
            var $tbody = $(selector + ' tbody');
            $tbody.empty();
            if (!items || items.length === 0) {
                $tbody.append('<tr><td colspan="2">{{ lang._("No data available") }}</td></tr>');
                return;
            }
            $.each(items.slice(0, 10), function(i, item) {
                $.each(item, function(name, count) {
                    $tbody.append(
                        '<tr><td>' + $('<span/>').text(name).html() + '</td>' +
                        '<td>' + formatNumber(count) + '</td></tr>'
                    );
                });
            });
        }

        function loadDashboard() {
            $('#dashboard-loading').show();
            $('#dashboard-error').hide();
            $('#dashboard-content').hide();

            ajaxGet('/api/adguardhome/dashboard/status', {}, function(data, status) {
                $('#dashboard-loading').hide();

                if (status !== 'success' || data.error) {
                    $('#dashboard-error').text(data.error || '{{ lang._("Unable to load dashboard data.") }}').show();
                    return;
                }

                $('#dashboard-content').show();

                // Service status
                if (data.running) {
                    $('#svc-status').html('<span class="label label-opnsense label-opnsense-default"><i class="fa fa-play fa-fw"></i> {{ lang._("Running") }}</span>');
                } else {
                    $('#svc-status').html('<span class="label label-opnsense label-opnsense-danger"><i class="fa fa-stop fa-fw"></i> {{ lang._("Stopped") }}</span>');
                }
                $('#svc-version').text(data.version || '{{ lang._("Unknown") }}');
                if (data.protection_enabled) {
                    $('#svc-protection').html('<span class="label label-opnsense label-opnsense-default">{{ lang._("Enabled") }}</span>');
                } else {
                    $('#svc-protection').html('<span class="label label-opnsense label-opnsense-danger">{{ lang._("Disabled") }}</span>');
                }

                // Summary stats
                var totalQueries = data.num_dns_queries || 0;
                var blockedQueries = (data.num_blocked_filtering || 0)
                    + (data.num_replaced_safebrowsing || 0)
                    + (data.num_replaced_parental || 0)
                    + (data.num_replaced_safesearch || 0);
                var pct = totalQueries > 0 ? ((blockedQueries / totalQueries) * 100).toFixed(1) : '0.0';

                $('#stat-total-queries').text(formatNumber(totalQueries));
                $('#stat-blocked-queries').text(formatNumber(blockedQueries));
                $('#stat-blocked-pct').text(pct + '%');
                $('#stat-avg-time').text(formatTime(data.avg_processing_time));

                // Top tables
                buildTopTable('#top-queried', data.top_queried_domains);
                buildTopTable('#top-blocked', data.top_blocked_domains);
                buildTopTable('#top-clients', data.top_clients);
            });
        }

        loadDashboard();
        updateServiceControlUI('adguardhome');

        $('#btn-refresh').click(function() {
            loadDashboard();
        });
    });
</script>

<div id="dashboard-loading" class="text-center" style="padding: 3em;">
    <i class="fa fa-spinner fa-pulse fa-2x"></i>
</div>

<div id="dashboard-error" class="alert alert-warning" style="display:none;"></div>

<div id="dashboard-content" style="display:none;">
    <!-- Service Status -->
    <div class="content-box">
        <div class="content-box-header">
            <h3>{{ lang._('Service') }}
                <button class="btn btn-default btn-xs pull-right" id="btn-refresh">
                    <i class="fa fa-refresh"></i> {{ lang._('Refresh') }}
                </button>
            </h3>
        </div>
        <div class="content-box-main">
            <table class="table table-condensed">
                <tbody>
                    <tr>
                        <td style="width:15%;">{{ lang._('Status') }}</td>
                        <td id="svc-status"></td>
                    </tr>
                    <tr>
                        <td>{{ lang._('Version') }}</td>
                        <td id="svc-version"></td>
                    </tr>
                    <tr>
                        <td>{{ lang._('DNS Protection') }}</td>
                        <td id="svc-protection"></td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Summary Statistics -->
    <div class="content-box">
        <div class="content-box-header">
            <h3>{{ lang._('Statistics') }}</h3>
        </div>
        <div class="content-box-main">
            <div class="row">
                <div class="col-md-3 col-sm-6">
                    <div class="panel panel-default">
                        <div class="panel-body text-center">
                            <h2 id="stat-total-queries" style="margin:0;">0</h2>
                            <small class="text-muted">{{ lang._('Total Queries') }}</small>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6">
                    <div class="panel panel-default">
                        <div class="panel-body text-center">
                            <h2 id="stat-blocked-queries" style="margin:0;">0</h2>
                            <small class="text-muted">{{ lang._('Blocked') }}</small>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6">
                    <div class="panel panel-default">
                        <div class="panel-body text-center">
                            <h2 id="stat-blocked-pct" style="margin:0;">0%</h2>
                            <small class="text-muted">{{ lang._('Blocked (%)') }}</small>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6">
                    <div class="panel panel-default">
                        <div class="panel-body text-center">
                            <h2 id="stat-avg-time" style="margin:0;">0 ms</h2>
                            <small class="text-muted">{{ lang._('Avg. Processing Time') }}</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Top Tables -->
    <div class="row">
        <div class="col-md-4">
            <div class="content-box">
                <div class="content-box-header">
                    <h3>{{ lang._('Top Queried Domains') }}</h3>
                </div>
                <div class="content-box-main">
                    <table id="top-queried" class="table table-condensed table-striped table-responsive">
                        <thead>
                            <tr>
                                <th>{{ lang._('Domain') }}</th>
                                <th>{{ lang._('Queries') }}</th>
                            </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="content-box">
                <div class="content-box-header">
                    <h3>{{ lang._('Top Blocked Domains') }}</h3>
                </div>
                <div class="content-box-main">
                    <table id="top-blocked" class="table table-condensed table-striped table-responsive">
                        <thead>
                            <tr>
                                <th>{{ lang._('Domain') }}</th>
                                <th>{{ lang._('Blocked') }}</th>
                            </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="content-box">
                <div class="content-box-header">
                    <h3>{{ lang._('Top Clients') }}</h3>
                </div>
                <div class="content-box-main">
                    <table id="top-clients" class="table table-condensed table-striped table-responsive">
                        <thead>
                            <tr>
                                <th>{{ lang._('Client') }}</th>
                                <th>{{ lang._('Queries') }}</th>
                            </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
