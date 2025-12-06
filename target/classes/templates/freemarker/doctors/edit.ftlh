<!DOCTYPE html>
<html>
<head>
  <title>Edit Doctor</title>
</head>
<body>
  <#include "../common/header.ftlh">
  <#include "../common/util.ftlh">
  <div class="container mt-4">
    <div class="page-title d-flex align-items-center gap-2"><span class="emoji">✏️</span><h1 class="m-0">Edit Doctor</h1></div>
    <div class="card mt-3">
      <div class="card-body doctor-edit">
        <form action="/doctors/edit/${doctor.id}" method="post" class="row g-2">
          <div class="col-md-6"><label class="form-label">First name</label><input class="form-control" name="firstName" value="${doctor.firstName!''}" required></div>
          <div class="col-md-6"><label class="form-label">Last name</label><input class="form-control" name="lastName" value="${doctor.lastName!''}" required></div>
          <div class="col-md-6"><label class="form-label">Email</label><input class="form-control" name="email" value="${doctor.email!''}"></div>
          <div class="col-md-6"><label class="form-label">Phone</label><input class="form-control" name="phone" value="${doctor.phone!''}"></div>
          <div class="col-md-6"><label class="form-label">Specialization</label><input class="form-control" name="specialization" value="${doctor.specialization!''}"></div>
          <div class="col-md-6"><label class="form-label">Department</label>
            <select class="form-select" name="departmentId">
              <option value="">None</option>
              <#list departments as dep>
                <option value="${dep.id}" <#if doctor.department?? && (doctor.department.id == dep.id)>selected</#if>>${dep.name}</option>
              </#list>
            </select>
          </div>
          <div class="col-12 mt-2 doctor-actions">
            <a href="/doctors" class="btn btn-outline-secondary">Cancel</a>
            <button class="btn btn-primary" type="submit">Save</button>
          </div>
        </form>
      </div>
    </div>
  </div>
  <#include "../common/footer.ftlh">
</body>
</html>

