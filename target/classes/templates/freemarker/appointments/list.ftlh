<!DOCTYPE html>
<html>
<head>
    <title>Appointments</title>
    <!-- Styles included via header -->
</head>
<body>
    <#include "../common/header.ftlh">
    <#include "../common/util.ftlh">

    <div class="container">
        <div class="d-flex align-items-center mb-3">
            <div class="page-title d-flex align-items-center gap-2"><span class="emoji">📅</span><h1 class="m-0">Appointments</h1></div>
            <div class="ms-auto">
                <a href="/appointments" class="btn btn-outline-secondary btn-sm">Refresh</a>
            </div>
        </div>

        <#if success??>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                ${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </#if>

        <#if error??>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </#if>

        <div class="card mb-3">
            <div class="card-body">
                <h6 class="mb-2">Quick Schedule</h6>
                <form id="quickScheduleForm" method="post" action="/appointments/schedule/0" class="row g-2 align-items-end">
                    <div class="col-md-4">
                        <label class="form-label small">Patient</label>
                        <select id="qsPatient" class="form-select" required>
                            <option value="">-- Select patient --</option>
                            <#if patients??>
                                <#list patients as p>
                                    <option value="${p.id}">${p.firstName!''} ${p.lastName!''}</option>
                                </#list>
                            </#if>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label small">Date</label>
                        <input id="qsDate" type="date" class="form-control" required />
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small">Time</label>
                        <div class="input-group">
                            <input id="qsTime" type="time" class="form-control" required />
                            <select id="qsAmPm" class="form-select" style="max-width:90px">
                                <option value="">--</option>
                                <option value="AM">AM</option>
                                <option value="PM">PM</option>
                            </select>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label small">Purpose</label>
                        <input id="qsPurpose" type="text" class="form-control" placeholder="Checkup, Consultation..." required />
                    </div>
                    <div class="col-12 text-end">
                        <button id="qsSubmit" type="submit" class="btn btn-primary btn-sm">Schedule</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            (function(){
                var form = document.getElementById('quickScheduleForm');
                if(!form) return;
                form.addEventListener('submit', async function(e){
                    e.preventDefault();
                    var pid = document.getElementById('qsPatient').value;
                    var date = document.getElementById('qsDate').value;
                    var time = document.getElementById('qsTime').value;
                    var ampm = document.getElementById('qsAmPm').value;
                    var purpose = document.getElementById('qsPurpose').value.trim();

                    if(!pid){ alert('Please select a patient'); return; }
                    if(!date || !time){ alert('Please provide date and time'); return; }

                    var dtStr = '';
                    if(ampm && ampm.trim() !== ''){
                        // Convert 12-hour time + AM/PM to 24-hour time then ISO-like string
                        // `time` input is in HH:mm (01:00..12:59) or 00:00..23:59 depending on browser; handle both
                        var hh = 0, mm = 0;
                        var parts = time.split(":");
                        hh = parseInt(parts[0]||"0",10);
                        mm = parts[1]||"00";
                        if(ampm.toUpperCase() === 'PM' && hh < 12) hh += 12;
                        if(ampm.toUpperCase() === 'AM' && hh === 12) hh = 0;
                        var hhStr = (hh < 10 ? '0' : '') + hh;
                        dtStr = date + 'T' + hhStr + ':' + mm; // e.g. 2025-11-02T19:00
                    } else {
                        // Assume time is already 24-hour HH:mm; produce ISO-like string
                        dtStr = date + 'T' + time;
                    }

                    var payload = {
                        patientId: parseInt(pid),
                        appointmentDateTime: dtStr,
                        purpose: purpose,
                        notes: null,
                        status: 'SCHEDULED'
                    };

                    try{
                        var res = await fetch('/api/appointments', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify(payload)
                        });
                        if(res.ok){
                            // on success redirect back to appointments list
                            window.location.href = '/appointments';
                        } else {
                            var txt = await res.text();
                            alert('Error scheduling appointment: ' + txt);
                        }
                    } catch(err){
                        alert('Unexpected error: ' + err.message);
                    }
                });
            })();
        </script>

        <div class="card mb-3">
            <div class="card-body">
                <h6 class="mb-2">Today's Appointments</h6>
                <div class="table-responsive">
                    <table class="table table-striped table-hover mb-0">
                        <thead class="table-light small">
                            <tr><th>Time</th><th>Patient</th><th>Purpose</th><th>Status</th><th>Actions</th></tr>
                        </thead>
                        <tbody>
                            <#if todayAppointments?? && todayAppointments?has_content>
                                <#list todayAppointments as appointment>
                                    <tr>
                                        <td>${fmtDate(appointment.appointmentDateTime, "HH:mm")}</td>
                                        <td>${appointment.patient.firstName!''} ${appointment.patient.lastName!''}</td>
                                        <td>${appointment.purpose!''}</td>
                                        <td><span class="badge status-${(appointment.status?lower_case)!'scheduled'}">${(appointment.status)!'SCHEDULED'}</span></td>
                                        <td>
                                            <#if (appointment.status?upper_case) == 'SCHEDULED'>
                                                <div class="btn-group">
                                                    <a href="/appointments/complete/${appointment.id}" class="btn btn-sm btn-outline-success" title="Complete"><i class="bi bi-check-lg"></i></a>
                                                    <a href="/appointments/cancel/${appointment.id}" class="btn btn-sm btn-outline-danger" title="Cancel" onclick="return confirm('Cancel appointment?')"><i class="bi bi-x-lg"></i></a>
                                                </div>
                                            </#if>
                                        </td>
                                    </tr>
                                </#list>
                            <#else>
                                <tr><td colspan="5" class="text-center muted">No appointments for today</td></tr>
                            </#if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-body">
                <h6 class="mb-2">Upcoming Appointments</h6>
                <div class="table-responsive">
                    <table class="table table-striped table-hover mb-0">
                        <thead class="table-light small"><tr><th>Date</th><th>Time</th><th>Patient</th><th>Purpose</th><th>Status</th><th>Actions</th></tr></thead>
                        <tbody>
                            <#if upcomingAppointments?? && upcomingAppointments?has_content>
                                <#list upcomingAppointments as appointment>
                                    <tr>
                                        <td>${fmtDate(appointment.appointmentDateTime, "yyyy-MM-dd")}</td>
                                        <td>${fmtDate(appointment.appointmentDateTime, "HH:mm")}</td>
                                        <td>${appointment.patient.firstName!''} ${appointment.patient.lastName!''}</td>
                                        <td>${appointment.purpose!''}</td>
                                        <td><span class="badge status-${(appointment.status?lower_case)!'scheduled'}">${(appointment.status)!'SCHEDULED'}</span></td>
                                        <td>
                                            <#if (appointment.status?upper_case) == 'SCHEDULED'>
                                                <div class="btn-group">
                                                    <a href="/appointments/cancel/${appointment.id}" class="btn btn-sm btn-outline-danger" title="Cancel" onclick="return confirm('Cancel appointment?')"><i class="bi bi-x-lg"></i></a>
                                                </div>
                                            </#if>
                                        </td>
                                    </tr>
                                </#list>
                            <#else>
                                <tr><td colspan="6" class="text-center muted">No upcoming appointments</td></tr>
                            </#if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>

    <#include "../common/footer.ftlh">
</body>
</html>