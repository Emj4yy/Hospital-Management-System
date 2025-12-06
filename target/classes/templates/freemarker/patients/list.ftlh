<!DOCTYPE html>
<html>
<head>
    <title>Patient List</title>
</head>
<body>
    <#include "../common/header.ftlh">
    <#include "../common/util.ftlh">

    <div class="container">
        <div class="d-flex align-items-center mb-3">
            <div class="page-title d-flex align-items-center gap-2">
                <span class="emoji">🧑‍⚕️</span>
                <h1 class="m-0">Patient List</h1>
            </div>
            <div class="ms-auto d-flex gap-2">
                <a href="/patients/new" class="btn btn-success btn-sm"><i class="bi bi-person-plus me-1"></i> New Patient</a>
                <a href="/patients" class="btn btn-outline-secondary btn-sm">Refresh</a>
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
                <form action="/patients/search" method="get" class="mb-0">
                    <div class="input-group">
                        <input type="text" name="query" class="form-control form-control-sm" placeholder="Search patients..." value="${searchQuery!}">
                        <button class="btn btn-primary btn-sm" type="submit"><i class="bi bi-search"></i></button>
                    </div>
                </form>
            </div>
        </div>

        <div class="card">
            <div class="table-responsive">
                <table class="table table-striped table-hover mb-0">
                    <thead class="table-light small">
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <#if patients?? && patients?has_content>
                            <#list patients as patient>
                                <tr>
                                    <td>${patient.id}</td>
                                    <td>${patient.firstName!''} ${patient.lastName!''}</td>
                                    <td>${patient.email!'-'}</td>
                                    <td>${patient.phone!'-'}</td>
                                    <td class="text-end">
                                        <div class="btn-group">
                                            <a href="/patients/${patient.id}" class="btn btn-outline-info btn-sm" title="View"><i class="bi bi-eye"></i></a>
                                            <a href="/patients/edit/${patient.id}" class="btn btn-outline-primary btn-sm" title="Edit"><i class="bi bi-pencil"></i></a>
                                            <a href="/appointments/schedule/${patient.id}" class="btn btn-outline-success btn-sm" title="Schedule"><i class="bi bi-calendar-plus"></i></a>
                                            <a href="/patients/delete/${patient.id}" class="btn btn-outline-danger btn-sm" title="Delete" onclick="return confirm('Are you sure you want to delete this patient?')"><i class="bi bi-trash"></i></a>
                                        </div>
                                    </td>
                                </tr>
                            </#list>
                        <#else>
                            <tr>
                                <td colspan="5" class="text-center muted">No patients found</td>
                            </tr>
                        </#if>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <#include "../common/footer.ftlh">
</body>
</html>