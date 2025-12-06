<!DOCTYPE html>
<html>
<head>
  <title>Departments</title>
</head>
<body>
  <#include "../common/header.ftlh">
  <div class="container">
    <div class="d-flex align-items-center mb-3"><div class="page-title d-flex align-items-center gap-2"><span class="emoji">🏢</span><h1 class="m-0">Departments</h1></div><div class="ms-auto"><a href="/departments" class="btn btn-outline-secondary btn-sm">Refresh</a></div></div>
    <#if success??><div class="alert alert-success">${success}</div></#if>
    <div class="card mb-3 form-section">
      <div class="card-body">
        <form action="/departments" method="post" class="row g-2">
          <div class="col-md-4"><input class="form-control form-control-sm" name="name" placeholder="Name" required></div>
          <div class="col-md-6"><input class="form-control form-control-sm" name="description" placeholder="Description"></div>
          <div class="col-md-2"><button class="btn btn-primary btn-sm w-100">Add</button></div>
        </form>
      </div>
    </div>
    <div class="card">
      <div class="table-responsive">
        <table class="table table-striped table-hover mb-0">
          <thead class="table-light small"><tr><th>ID</th><th>Name</th><th>Description</th><th>Actions</th></tr></thead>
          <tbody>
            <#if departments?? && departments?has_content>
              <#list departments as d>
                <tr>
                  <td>${d.id}</td><td>${d.name}</td><td>${d.description!'-'}</td>
                  <td>
                    <form action="/departments/delete/${d.id}" method="post" onsubmit="return confirm('Delete department?')">
                      <button class="btn btn-outline-danger btn-sm">Delete</button>
                    </form>
                  </td>
                </tr>
              </#list>
            <#else>
              <tr><td colspan="4" class="text-center muted">No departments</td></tr>
            </#if>
          </tbody>
        </table>
      </div>
    </div>
  </div>
  <#include "../common/footer.ftlh">
</body>
</html>
