<!DOCTYPE html>
<html>
<head>
  <title>Prescription Details</title>
</head>
<body>
  <#include "../common/header.ftlh">
  <#include "../common/util.ftlh">
  <div class="container mt-3">
    <div class="page-title d-flex align-items-center gap-2"><span class="emoji">💊</span><h1 class="m-0">Prescription</h1></div>

    <div class="card form-section">
      <div class="card-body">
        <h5 class="card-title mb-2">Prescription #${prescription.id}</h5>
        <p><strong>Date Issued:</strong> ${fmtDate(prescription.dateIssued, "yyyy-MM-dd HH:mm")!'-'}</p>
        <p><strong>Patient:</strong> <a href="/patients/${prescription.patient.id}">${prescription.patient.firstName!''} ${prescription.patient.lastName!''}</a></p>
        <p><strong>Doctor:</strong> ${prescription.doctor.firstName!''} ${prescription.doctor.lastName!''} <span class="muted">(${prescription.doctor.specialization!'-'})</span></p>
        <p><strong>Medications:</strong> ${prescription.medications!'-'}</p>
        <p><strong>Notes:</strong> ${prescription.notes!'-'}</p>

        <div class="mt-3 d-flex gap-2">
          <a href="/prescriptions" class="btn btn-outline-secondary btn-sm">Back</a>
          <form action="/prescriptions/delete/${prescription.id}" method="post" onsubmit="return confirm('Delete prescription?')">
            <button class="btn btn-danger btn-sm">Delete</button>
          </form>
        </div>
      </div>
    </div>
  </div>
  <#include "../common/footer.ftlh">
</body>
</html>
