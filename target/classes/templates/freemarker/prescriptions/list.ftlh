<!DOCTYPE html>
<html>
<head>
  <title>Prescriptions</title>
</head>
<body>
  <#include "../common/header.ftlh">
  <#include "../common/util.ftlh">
  <div class="container">
    <div class="page-title"><span class="emoji">💊</span><h1 class="m-0">Prescriptions</h1></div>
    <div id="alertPlaceholder"></div>
    <#if success??><div class="alert alert-success">${success}</div></#if>
    <div class="form-section mb-3">
      <form id="prescriptionForm" class="row g-2 align-items-end">
        <div class="col-md-3">
          <label class="form-label visually-hidden">Patient</label>
          <select class="form-select" id="prPatientId" required>
            <option value="">Patient</option>
            <#list patients as p>
              <option value="${p.id}">${p.firstName} ${p.lastName}</option>
            </#list>
          </select>
        </div>
        <div class="col-md-3">
          <label class="form-label visually-hidden">Doctor</label>
          <select class="form-select" id="prDoctorId" required>
            <option value="">Doctor</option>
            <#list doctors as d>
              <option value="${d.id}">${d.firstName} ${d.lastName}</option>
            </#list>
          </select>
        </div>
        <div class="col-md-4">
          <label class="form-label visually-hidden">Medications</label>
          <input class="form-control" id="prMedications" placeholder="Medications (comma separated)">
        </div>
        <div class="col-md-2">
          <button id="prAddBtn" class="btn btn-primary w-100" type="submit">Add</button>
        </div>
        <div class="col-12 mt-2"><input class="form-control" id="prNotes" placeholder="Notes"></div>
      </form>
    </div>
    <div class="table-responsive">
      <table class="table table-striped table-hover">
        <thead><tr><th>ID</th><th>Date</th><th>Patient</th><th>Doctor</th><th>Medications</th><th>Notes</th><th>Actions</th></tr></thead>
        <tbody>
          <#list prescriptions as pr>
            <tr data-prescription-id="${pr.id}">
              <td>${pr.id}</td>
              <td>${fmtDate(pr.dateIssued, "yyyy-MM-dd")!'-'}</td>
              <td><a href="/patients/${pr.patient.id}">${pr.patient.firstName!''} ${pr.patient.lastName!''}</a></td>
              <td>${pr.doctor.firstName!''} ${pr.doctor.lastName!''} <span class="muted small">(${(pr.doctor.specialization)!'-'})</span></td>
              <td>${pr.medications?if_exists?string!'-'}</td>
              <td>${pr.notes!'-'}</td>
              <td>
                <div class="d-flex gap-1">
                  <button class="btn btn-sm btn-danger pr-delete-btn" data-id="${pr.id}">Delete</button>
                  <a href="/prescriptions/view/${pr.id}" data-href="/prescriptions/view/${pr.id}" class="btn btn-sm btn-outline-secondary pr-view-link">View</a>
                </div>
              </td>
            </tr>
          <#else><tr><td colspan="7" class="text-center">No prescriptions</td></tr>
          </#list>
        </tbody>
      </table>
    </div>
  </div>

  <script>
    (function(){
      const alertPlaceholder = document.getElementById('alertPlaceholder');
      // Robust navigation for View links: ensure anchors navigate via location.href to avoid accidental static-resource fetches
      document.querySelectorAll('.pr-view-link').forEach(a => a.addEventListener('click', function(e){
        // Let normal Ctrl/Cmd+click or middle-click behave naturally
        if (e.ctrlKey || e.metaKey || e.button === 1) return;
        e.preventDefault();
        const href = this.dataset.href || this.getAttribute('href');
        if(href) location.href = href;
      }));

      function showAlert(message, type){
        alertPlaceholder.innerHTML = '<div class="alert alert-' + type + ' alert-dismissible fade show" role="alert">' + message + '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button></div>';
      }

      const form = document.getElementById('prescriptionForm');
      form && form.addEventListener('submit', async function(e){
        e.preventDefault();
        const patientId = document.getElementById('prPatientId').value;
        const doctorId = document.getElementById('prDoctorId').value;
        const meds = document.getElementById('prMedications').value.trim();
        const notes = document.getElementById('prNotes').value.trim();
        if(!patientId || !doctorId || !meds){ showAlert('Patient, doctor and medications are required', 'warning'); return; }
        const payload = { patient: { id: Number(patientId) }, doctor: { id: Number(doctorId) }, medications: meds, notes: notes };
        try{
          const res = await fetch('/api/prescriptions', { method: 'POST', headers: { 'Content-Type':'application/json' }, body: JSON.stringify(payload) });
          if(res.ok){ showAlert('Prescription saved','success'); setTimeout(()=> location.reload(),700); }
          else { const txt = await res.text(); showAlert('Error: '+txt,'danger'); }
        }catch(err){ showAlert('Unexpected error: '+err.message,'danger'); }
      });

      // Delete buttons
      document.querySelectorAll('.pr-delete-btn').forEach(btn => btn.addEventListener('click', async function(e){
        const id = this.dataset.id;
        if(!confirm('Delete prescription?')) return;
        try{
          const res = await fetch('/api/prescriptions/'+id, { method: 'DELETE' });
          if(res.ok || res.status===204){ showAlert('Prescription deleted','success'); setTimeout(()=> location.reload(),500); }
          else { const txt = await res.text(); showAlert('Error: '+txt,'danger'); }
        }catch(err){ showAlert('Unexpected error: '+err.message,'danger'); }
      }));
    })();
  </script>

  <#include "../common/footer.ftlh">
</body>
</html>
