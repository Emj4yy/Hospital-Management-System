<!DOCTYPE html>
<html>
<head>
    <title>Patient Details</title>
</head>
<body>
    <#include "../common/header.ftlh">
    <#include "../common/util.ftlh">

    <div class="container mt-4">
        <div class="d-flex align-items-center mb-3">
            <div class="page-title d-flex align-items-center gap-2"><span class="emoji">📄</span><h1 class="m-0">Patient Details</h1></div>
            <div class="ms-auto d-flex gap-2"><a href="/appointments/schedule/${patient.id}" class="btn btn-outline-success btn-sm"><i class="bi bi-calendar-plus me-1"></i> Schedule</a></div>
        </div>

        <div class="card mb-4">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-start mb-3">
                    <h5 class="card-title">Personal Information</h5>
                    <div class="muted">Patient ID: ${patient.id}</div>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <p><strong>Name:</strong> ${patient.firstName!''} ${patient.lastName!''}</p>
                        <p><strong>Email:</strong> ${patient.email!'-'}</p>
                        <p><strong>Phone:</strong> ${patient.phone!'-'}</p>
                    </div>
                    <div class="col-md-6">
                        <p><strong>Date of Birth:</strong> ${fmtDate(patient.dateOfBirth, "yyyy-MM-dd")!'-'}</p>
                        <p><strong>Address:</strong> ${patient.address!'-'}</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="mb-4 d-flex gap-2">
            <a href="/patients" class="btn btn-outline-secondary btn-sm">Back to List</a>
            <a href="/patients/edit/${patient.id}" class="btn btn-primary btn-sm">Edit</a>
        </div>
    </div>

    <#include "../common/footer.ftlh">
</body>
</html>