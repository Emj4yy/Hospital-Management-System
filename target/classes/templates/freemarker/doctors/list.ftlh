<!DOCTYPE html>
<html>
<head>
  <title>Doctors</title>
</head>
<body>
  <#include "../common/header.ftlh">
  <#include "../common/util.ftlh">
  <div class="container">
    <div class="d-flex align-items-center mb-3">
      <div class="page-title d-flex align-items-center gap-2"><span class="emoji">👨‍⚕️</span><h1 class="m-0">Doctors</h1></div>
      <div class="ms-auto">
        <a href="/doctors" class="btn btn-outline-secondary btn-sm">Refresh</a>
      </div>
    </div>

    <div class="card mb-3">
      <div class="card-body">
        <form action="/doctors" method="post" class="row g-2">
          <div class="col-md-3"><input class="form-control form-control-sm" name="firstName" placeholder="First name" required></div>
          <div class="col-md-3"><input class="form-control form-control-sm" name="lastName" placeholder="Last name" required></div>
          <div class="col-md-3"><input class="form-control form-control-sm" name="email" placeholder="Email"></div>
          <div class="col-md-3"><input class="form-control form-control-sm" name="phone" placeholder="Phone"></div>
          <div class="col-md-4"><input class="form-control form-control-sm" name="specialization" placeholder="Specialization"></div>
          <div class="col-md-4">
            <select class="form-select form-select-sm" name="departmentId">
              <option value="">Department</option>
              <#list departments as dep>
                <option value="${dep.id}">${dep.name}</option>
              </#list>
            </select>
          </div>
          <div class="col-md-4"><button class="btn btn-primary btn-sm w-100">Add Doctor</button></div>
        </form>
      </div>
    </div>

    <div class="card">
      <div class="table-responsive">
        <table class="table table-striped table-hover mb-0">
          <thead class="table-light small"><tr><th>ID</th><th>Name</th><th>Dept</th><th>Spec</th><th>Email</th><th>Phone</th><th>Actions</th></tr></thead>
          <tbody>
            <#if doctors?? && doctors?has_content>
              <#list doctors as d>
                <tr>
                  <td>${d.id}</td>
                  <td>${d.firstName!''} ${d.lastName!''}</td>
                  <td>${(d.department.name)!'-'}</td>
                  <td>${d.specialization!'-'}</td>
                  <td>${d.email!'-'}</td>
                  <td>${d.phone!'-'}</td>
                  <td>
                    <div class="btn-group doctor-actions">
                      <a href="/doctors/edit/${d.id}" class="btn btn-outline-primary btn-sm">Edit</a>
                      <form action="/doctors/delete/${d.id}" method="post" onsubmit="return confirm('Delete doctor?')">
                        <button class="btn btn-outline-danger btn-sm">Delete</button>
                      </form>
                    </div>
                  </td>
                </tr>
              </#list>
            <#else>
              <tr><td colspan="7" class="text-center muted">No doctors</td></tr>
            </#if>
          </tbody>
        </table>
      </div>
    </div>
  </div>
  <#include "../common/footer.ftlh">
</body>
</html>
