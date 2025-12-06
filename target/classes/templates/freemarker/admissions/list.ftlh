<!DOCTYPE html>
<html>
<head>
  <title>Admissions</title>
  <style>
    /* Inline critical styles to guarantee visibility for discharged badge */
    .badge.status-discharged,
    [class*="status-discharged" i] {
      background: linear-gradient(90deg,#374151,#1f2937) !important;
      color: #fff !important;
      border: 1px solid rgba(0,0,0,0.12) !important;
      box-shadow: 0 2px 6px rgba(31,41,55,0.12) !important;
      padding: .35em .5em !important;
      border-radius: .4rem !important;
    }
  </style>
</head>
<body>
  <#include "../common/header.ftlh">
  <#include "../common/util.ftlh">
  <div class="container">
    <div class="page-title"><span class="emoji">🏨</span><h1 class="m-0">Admissions</h1></div>
    <div id="alertPlaceholder"></div>
    <#if success??><div class="alert alert-success">${success}</div></#if>

    <!-- Filter form (unchanged) -->
    <div class="card mb-3 form-section">
      <div class="card-body">
        <form action="/admissions" method="get" class="row g-2 align-items-end">
          <div class="col-md-2">
            <select class="form-select form-select-sm" name="status">
              <option value="">Status (All)</option>
              <option value="ADMITTED" <#if filterStatus?exists && (filterStatus == 'ADMITTED')>selected</#if>>ADMITTED</option>
              <option value="DISCHARGED" <#if filterStatus?exists && (filterStatus == 'DISCHARGED')>selected</#if>>DISCHARGED</option>
            </select>
          </div>
          <div class="col-md-2"><input class="form-control form-control-sm" type="date" name="from" value="${filterFrom!''}"></div>
          <div class="col-md-2"><input class="form-control form-control-sm" type="date" name="to" value="${filterTo!''}"></div>
          <div class="col-md-3">
            <select class="form-select form-select-sm" name="patientId">
              <option value="">Patient (All)</option>
              <#list patients as p>
                <option value="${p.id}" <#if filterPatientId?exists && (filterPatientId?string == (p.id?string))>selected</#if>>${p.firstName} ${p.lastName}</option>
              </#list>
            </select>
          </div>
          <div class="col-md-2">
            <select class="form-select form-select-sm" name="doctorId">
              <option value="">Doctor (All)</option>
              <#list doctors as d>
                <option value="${d.id}" <#if filterDoctorId?exists && (filterDoctorId?string == (d.id?string))>selected</#if>>${d.firstName} ${d.lastName} - ${(d.department.name)!'-'}</option>
              </#list>
            </select>
          </div>
          <div class="col-md-1"><button class="btn btn-outline-secondary btn-sm w-100">Filter</button></div>
        </form>
      </div>
    </div>

    <div class="form-section mb-3">
      <form id="admitForm" class="row g-2">
        <div class="col-md-4">
          <select class="form-select" id="adPatientId" required>
            <option value="">Select Patient</option>
            <#list patients as p>
              <option value="${p.id}">${p.firstName} ${p.lastName}</option>
            </#list>
          </select>
        </div>
        <div class="col-md-4">
          <select class="form-select" id="adDoctorId" required>
            <option value="">Select Doctor</option>
            <#list doctors as d>
              <option value="${d.id}">${d.firstName} ${d.lastName} - ${(d.department.name)!'-'}</option>
            </#list>
          </select>
        </div>
        <div class="col-md-3"><input class="form-control" id="adRoom" placeholder="Room Number"></div>
        <div class="col-md-1"><button class="btn btn-primary w-100" id="admitBtn" type="submit">Admit</button></div>
      </form>
    </div>

    <div class="table-responsive">
      <table class="table table-striped table-hover">
        <thead><tr><th>ID</th><th>Patient</th><th>Doctor</th><th>Room</th><th>Status</th><th>Admitted</th><th>Discharged</th><th>Actions</th></tr></thead>
        <tbody>
          <#list admissions as a>
            <tr data-admission-id="${a.id}">
              <td>${a.id}</td>
              <td>${a.patient.firstName} ${a.patient.lastName}</td>
              <td>${a.doctor.firstName} ${a.doctor.lastName}</td>
              <td>${a.roomNumber!'-'}</td>
              <td>
                <#if (a.status?upper_case) == 'DISCHARGED'>
                  <span class="badge status-discharged" style="background:linear-gradient(90deg,#374151,#1f2937);color:#fff;border:1px solid rgba(0,0,0,0.12);box-shadow:0 2px 6px rgba(31,41,55,0.12);padding:.35em .5em;border-radius:.4rem;display:inline-block">${a.status}</span>
                <#else>
                  <span class="badge status-${(a.status?lower_case)!}">${a.status}</span>
                </#if>
              </td>
              <td>${fmtDate(a.admittedAt, "yyyy-MM-dd HH:mm")}</td>
              <td>${(a.dischargedAt?has_content)?then(fmtDate(a.dischargedAt, "yyyy-MM-dd HH:mm"), '-')}
              </td>
              <td>
                <#if a.status != 'DISCHARGED'>
                  <button class="btn btn-sm btn-success ad-discharge-btn" data-id="${a.id}">Discharge</button>
                </#if>
              </td>
            </tr>
          <#else><tr><td colspan="8" class="text-center">No admissions</td></tr>
          </#list>
        </tbody>
      </table>
    </div>
  </div>

  <script>
    (function(){
      const alertPlaceholder = document.getElementById('alertPlaceholder');
      function showAlert(message, type){
        alertPlaceholder.innerHTML = '<div class="alert alert-' + type + ' alert-dismissible fade show" role="alert">' + message + '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button></div>';
      }

      const admitForm = document.getElementById('admitForm');
      admitForm && admitForm.addEventListener('submit', async function(e){
        e.preventDefault();
        const patientId = Number(document.getElementById('adPatientId').value);
        const doctorId = Number(document.getElementById('adDoctorId').value);
        const room = document.getElementById('adRoom').value.trim() || null;
        if(!patientId || !doctorId){ showAlert('Patient and doctor are required','warning'); return; }
        const payload = { patient: { id: patientId }, doctor: { id: doctorId }, roomNumber: room };
        try{
          const res = await fetch('/api/admissions', { method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify(payload) });
          if(res.ok){ showAlert('Patient admitted','success'); setTimeout(()=> location.reload(),700); }
          else { const txt = await res.text(); showAlert('Error: '+txt,'danger'); }
        }catch(err){ showAlert('Unexpected: '+err.message, 'danger'); }
      });

      // Discharge buttons
      document.querySelectorAll('.ad-discharge-btn').forEach(btn => btn.addEventListener('click', async function(e){
        const id = this.dataset.id;
        if(!confirm('Discharge patient?')) return;
        try{
          const res = await fetch('/api/admissions/'+id+'/discharge', { method: 'PUT' });
          if(res.ok){ showAlert('Patient discharged','success'); setTimeout(()=> location.reload(),500); }
          else { const txt = await res.text(); showAlert('Error: '+txt,'danger'); }
        }catch(err){ showAlert('Unexpected error: '+err.message,'danger'); }
      }));
    })();
  </script>

  <#include "../common/footer.ftlh">
</body>
</html>
