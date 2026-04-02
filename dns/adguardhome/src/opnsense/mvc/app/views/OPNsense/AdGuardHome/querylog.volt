<script>
    $(document).ready(function() {
        $("#queryLogGrid").UIBootgrid({
            search: '/api/adguardhome/querylog/search/',
            options: {
                sorting: true,
                selection: false,
                multiSelect: false,
                rowCount: [25, 50, 100, -1],
                formatters: {
                    "time": function(column, row) {
                        if (!row.time) return '';
                        var d = new Date(row.time);
                        if (isNaN(d.getTime())) return row.time;
                        return d.toLocaleString();
                    }
                }
            }
        });

        updateServiceControlUI('adguardhome');
    });
</script>

<div class="content-box">
    <div class="content-box-main">
        <table id="queryLogGrid" class="table table-condensed table-hover table-striped">
            <thead>
                <tr>
                    <th data-column-id="time" data-formatter="time" data-order="desc" data-width="13em">{{ lang._('Time') }}</th>
                    <th data-column-id="request">{{ lang._('Request') }}</th>
                    <th data-column-id="response">{{ lang._('Response') }}</th>
                    <th data-column-id="client" data-width="12em">{{ lang._('Client') }}</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    </div>
</div>
