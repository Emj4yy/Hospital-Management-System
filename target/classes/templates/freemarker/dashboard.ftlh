<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
    <!-- Styles included via header -->
</head>
<body>
    <#include "common/header.ftlh">
    <#include "common/util.ftlh">

    <div class="container">
        <div class="page-title">
            <span class="emoji">🏥</span>
            <h1 class="m-0">Dashboard</h1>
        </div>

        <!-- Expanded Statistics Cards -->
        <div class="row g-3 mt-2">
            <div class="col-md-3">
                <div class="card stat-card p-2">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="stat-icon bg-soft-primary me-3"><i class="bi bi-people-fill"></i></div>
                            <div>
                                <h6 class="text-muted mb-1">Total Patients</h6>
                                <div class="stat-value"><span id="statTotalPatients">${totalPatients!0}</span></div>
                                <div class="muted small">Registered patients</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card p-2">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="stat-icon bg-soft-success me-3"><i class="bi bi-person-plus"></i></div>
                            <div>
                                <h6 class="text-muted mb-1">New Patients Today</h6>
                                <#-- Count patients with createdAt today if available -->
                                <#assign newToday = 0>
                                <#if patients??>
                                    <#list patients as p>
                                        <#-- assume p.createdAt may exist -->
                                        <#if p.createdAt?has_content>
                                            <#-- compare date portion -->
                                            <#if fmtDate(p.createdAt, "yyyy-MM-dd") == .now?string("yyyy-MM-dd")>
                                                <#assign newToday = newToday + 1>
                                            </#if>
                                        </#if>
                                    </#list>
                                </#if>
                                <div class="stat-value"><span id="statNewPatientsToday">${newToday}</span></div>
                                <div class="muted small">Registered today</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card p-2">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="stat-icon bg-soft-info me-3"><i class="bi bi-calendar3"></i></div>
                            <div>
                                <h6 class="text-muted mb-1">Today's Appointments</h6>
                                <div class="stat-value"><span id="statTodayAppointments">${(todayAppointments?size)!0}</span></div>
                                <div class="muted small">Appointments scheduled for today</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card p-2">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="stat-icon bg-soft-warning me-3"><i class="bi bi-person-badge-fill"></i></div>
                            <div>
                                <h6 class="text-muted mb-1">Total Doctors</h6>
                                <div class="stat-value">${(totalDoctors)!0}</div>
                                <div class="muted small">Active doctors</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <#-- Extra stats row for unpaid invoices and others -->
        <div class="row g-3 mt-2">
            <div class="col-md-3">
                <div class="card stat-card p-2">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="stat-icon bg-soft-danger me-3"><i class="bi bi-wallet2"></i></div>
                            <div>
                                <h6 class="text-muted mb-1">Unpaid Invoice Total</h6>
                                <#assign unpaidTotal = 0.0>
                                <#if invoices??>
                                    <#list invoices as inv>
                                        <#if (inv.status?upper_case) != 'PAID'>
                                            <#-- Safely coerce amount to number -->
                                            <#attempt>
                                                <#assign amt = inv.amount?number>
                                                <#assign unpaidTotal = unpaidTotal + amt>
                                            <#recover>
                                                <#-- ignore non-numeric amounts -->
                                            </#attempt>
                                        </#if>
                                    </#list>
                                </#if>
                                <div class="stat-value">$<span id="statUnpaidTotal">${unpaidTotal?string("0.00")}</span></div>
                                <div class="muted small">Outstanding</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Compact upcoming -->
        <div class="row mt-3 g-3">
            <div class="col-md-8">

                <!-- Recent Admissions -->
                <div class="card p-3 mt-3">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="m-0">Recent Admissions</h5>
                        <a href="/admissions" class="small muted">View all</a>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-sm">
                            <thead>
                                <tr><th>ID</th><th>Patient</th><th>Room</th><th>Status</th></tr>
                            </thead>
                            <tbody>
                                <#if admissions?? && admissions?has_content>
                                    <#list admissions as adm>
                                        <#if adm?index lt 5>
                                            <tr>
                                                <td>${adm.id}</td>
                                                <td>${adm.patient.firstName!''} ${adm.patient.lastName!''}</td>
                                                <td>${adm.roomNumber!'-'}</td>
                                                <td><span class="badge status-${(adm.status?lower_case)!}">${adm.status}</span></td>
                                            </tr>
                                        </#if>
                                    </#list>
                                <#else>
                                    <tr><td colspan="4" class="text-center muted">No recent admissions</td></tr>
                                </#if>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>

            <div class="col-md-4">
                <!-- Compact Upcoming Appointments -->
                <div class="card p-3">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="m-0">Upcoming</h5>
                        <a href="/appointments" class="small muted">View all</a>
                    </div>
                    <#if upcomingAppointments?? && upcomingAppointments?has_content>
                        <ul class="list-unstyled small">
                            <#list upcomingAppointments as ua>
                                <#if ua?index lt 6>
                                    <li class="py-1">
                                        <strong>${fmtDate(ua.appointmentDateTime, "yyyy-MM-dd HH:mm")}</strong>
                                        <div class="muted">${ua.patient.firstName!''} ${ua.patient.lastName!''} — ${ua.purpose!''}</div>
                                    </li>
                                </#if>
                            </#list>
                        </ul>
                    <#else>
                        <div class="muted small">No upcoming appointments</div>
                    </#if>
                </div>

                <!-- Recent Prescriptions -->
                <div class="card p-3 mt-3">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="m-0">Recent Prescriptions</h5>
                        <a href="/prescriptions" class="small muted">View all</a>
                    </div>
                    <ul class="list-unstyled small">
                        <#if prescriptions?? && prescriptions?has_content>
                            <#list prescriptions as pr>
                                <#if pr?index lt 5>
                                    <li class="py-1">${fmtDate(pr.dateIssued, "yyyy-MM-dd")} — ${pr.patient.firstName!''} ${pr.patient.lastName!''}</li>
                                </#if>
                            </#list>
                        <#else>
                            <li class="muted">No prescriptions</li>
                        </#if>
                    </ul>
                </div>

                <!-- Recent Invoices -->
                <div class="card p-3 mt-3">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="m-0">Recent Invoices</h5>
                        <a href="/billing" class="small muted">View all</a>
                    </div>
                    <ul class="list-unstyled small">
                        <#if invoices?? && invoices?has_content>
                            <#list invoices as inv>
                                <#if inv?index lt 5>
                                    <li class="py-1">#${inv.id} — $${inv.amount} — <span class="badge status-${(inv.status?lower_case)!}">${inv.status}</span></li>
                                </#if>
                            </#list>
                        <#else>
                            <li class="muted">No invoices</li>
                        </#if>
                    </ul>
                </div>

            </div>
        </div>


    </div>

    <!-- Live stats updater -->
    <script>
        (function(){
            var endpoint = '/dashboard/stats';
            function fmtCurrency(value){
                try{ return '$' + parseFloat(value).toFixed(2); }catch(e){return '$0.00';}
            }
            function updateStats(data){
                if(!data || !data.ok) return;
                if(document.getElementById('statTotalPatients')) document.getElementById('statTotalPatients').textContent = data.totalPatients || '0';
                // newPatientsToday may be zero if server can't compute it yet
                if(document.getElementById('statNewPatientsToday')) document.getElementById('statNewPatientsToday').textContent = data.newPatientsToday || '0';
                if(document.getElementById('statTodayAppointments')) document.getElementById('statTodayAppointments').textContent = data.todayAppointmentsCount || '0';
                if(document.getElementById('statUnpaidTotal')) document.getElementById('statUnpaidTotal').textContent = (data.unpaidTotal !== undefined) ? data.unpaidTotal : '0.00';
            }
            async function poll(){
                try{
                    var res = await fetch(endpoint, {cache:'no-store'});
                    if(!res.ok) return;
                    var j = await res.json();
                    updateStats(j);
                }catch(e){console.warn('Failed to update dashboard stats', e)}
            }
            // Initial poll shortly after load
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', function(){ setTimeout(poll, 800); });
            } else { setTimeout(poll, 800); }
            // Poll every 10s
            setInterval(poll, 10000);
        })();
    </script>

    <#include "common/footer.ftlh">
</body>
</html>