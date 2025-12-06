<!DOCTYPE html>
<html>
<head>
    <title>Edit Patient</title>
    <!-- Styles via header -->
</head>
<body>
    <#include "../common/header.ftlh">

    <div class="container">
        <div class="d-flex align-items-center mb-3">
            <div class="page-title d-flex align-items-center gap-2"><span class="emoji">✏️</span><h1 class="m-0">Edit Patient</h1></div>
            <div class="ms-auto"><a href="/patients" class="btn btn-outline-secondary btn-sm">Back</a></div>
        </div>

        <div class="card form-section">
            <div class="card-body">
                <form action="/patients/edit/${patient.id}" method="post">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label for="firstName" class="form-label">First Name</label>
                            <input type="text" class="form-control form-control-sm" id="firstName" name="firstName" value="${patient.firstName!''}" required>
                        </div>
                        <div class="col-md-6">
                            <label for="lastName" class="form-label">Last Name</label>
                            <input type="text" class="form-control form-control-sm" id="lastName" name="lastName" value="${patient.lastName!''}" required>
                        </div>
                        <div class="col-md-6">
                            <label for="email" class="form-label">Email</label>
                            <input type="email" class="form-control form-control-sm" id="email" name="email" value="${patient.email!''}">
                        </div>
                        <div class="col-md-6">
                            <label for="phone" class="form-label">Phone</label>
                            <input type="tel" class="form-control form-control-sm" id="phone" name="phone" value="${patient.phone!''}">
                        </div>
                        <div class="col-md-6">
                            <label for="dateOfBirth" class="form-label">Date of Birth</label>
                            <input type="date" class="form-control form-control-sm" id="dateOfBirth" name="dateOfBirth" value="${patient.dateOfBirth!''}">
                        </div>
                        <div class="col-12">
                            <label for="address" class="form-label">Address</label>
                            <textarea class="form-control form-control-sm" id="address" name="address" rows="3">${patient.address!''}</textarea>
                        </div>
                    </div>
                    <div class="mt-3 d-flex gap-2">
                        <button type="submit" class="btn btn-primary btn-sm">Save Changes</button>
                        <a href="/patients" class="btn btn-secondary btn-sm">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <#include "../common/footer.ftlh">
</body>
</html>