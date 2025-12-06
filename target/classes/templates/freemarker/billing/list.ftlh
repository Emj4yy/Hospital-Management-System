<!DOCTYPE html>
<html>
<head>
  <title>Billing</title>
</head>
<body>
  <#include "../common/header.ftlh">
  <#include "../common/util.ftlh">
  <div class="container">
    <div class="d-flex align-items-center mb-3"><div class="page-title d-flex align-items-center gap-2"><span class="emoji">💳</span><h1 class="m-0">Billing</h1></div><div class="ms-auto"><a href="/billing" class="btn btn-outline-secondary btn-sm">Refresh</a></div></div>
    <div id="alertPlaceholder"></div>
    <#if success??><div class="alert alert-success">${success}</div></#if>

    <!-- Filter form (unchanged) -->
    <div class="card mb-3 form-section">
      <div class="card-body">
        <form action="/billing" method="get" class="row g-2 align-items-end">
          <div class="col-md-3">
            <select class="form-select form-select-sm" name="status">
              <option value="">Status (All)</option>
              <option value="UNPAID" <#if filterStatus?exists && (filterStatus == 'UNPAID')>selected</#if>>UNPAID</option>
              <option value="PAID" <#if filterStatus?exists && (filterStatus == 'PAID')>selected</#if>>PAID</option>
            </select>
          </div>
          <div class="col-md-3"><input class="form-control form-control-sm" type="date" name="from" value="${filterFrom!''}"></div>
          <div class="col-md-3"><input class="form-control form-control-sm" type="date" name="to" value="${filterTo!''}"></div>
          <div class="col-md-2">
            <select class="form-select form-select-sm" name="patientId">
              <option value="">Patient (All)</option>
              <#list patients as p>
                <option value="${p.id}" <#if filterPatientId?exists && (filterPatientId?string == (p.id?string))>selected</#if>>${p.firstName} ${p.lastName}</option>
              </#list>
            </select>
          </div>
          <div class="col-md-1"><button class="btn btn-outline-secondary btn-sm w-100">Filter</button></div>
        </form>
      </div>
    </div>

    <!-- Create invoice form (converted to REST) -->
    <div class="card mb-3 form-section">
      <div class="card-body">
        <form id="invoiceForm" class="row g-2 align-items-end">
          <div class="col-md-4">
            <select class="form-select form-select-sm" id="invPatientId" required>
              <option value="">Select Patient</option>
              <#list patients as p>
                <option value="${p.id}">${p.firstName} ${p.lastName}</option>
              </#list>
            </select>
          </div>
          <div class="col-md-3"><input class="form-control form-control-sm" id="invAmount" placeholder="Amount" type="number" step="0.01" required></div>
          <div class="col-md-4"><input class="form-control form-control-sm" id="invDescription" placeholder="Description"></div>
          <div class="col-md-1"><button id="invCreateBtn" class="btn btn-primary btn-sm w-100" type="submit">Create</button></div>
        </form>
      </div>
    </div>

    <div class="card">
      <div class="table-responsive">
        <table class="table table-striped table-hover mb-0">
          <thead class="table-light small"><tr><th>ID</th><th>Patient</th><th>Amount</th><th>Description</th><th>Status</th><th>Issued</th><th>Paid</th><th>Actions</th></tr></thead>
          <tbody>
            <#if invoices?? && invoices?has_content>
              <#list invoices as inv>
                <tr data-invoice-id="${inv.id}">
                  <td>${inv.id}</td>
                  <td>${inv.patient.firstName!''} ${inv.patient.lastName!''}</td>
                  <td>$${inv.amount}</td>
                  <td>${inv.description!'-'}</td>
                  <td><span class="badge status-${(inv.status?lower_case)!}">${inv.status}</span></td>
                  <td>${fmtDate(inv.issuedAt, "yyyy-MM-dd HH:mm")}</td>
                  <td>${(inv.paidAt?has_content)?then(fmtDate(inv.paidAt, "yyyy-MM-dd HH:mm"), '-')}</td>
                  <td>
                    <#if (inv.status?upper_case) != 'PAID'>
                      <button class="btn btn-sm btn-outline-success inv-pay-btn" data-id="${inv.id}" title="Mark as Paid">Mark as Paid</button>
                    </#if>
                  </td>
                </tr>
              </#list>
            <#else>
              <tr><td colspan="8" class="text-center muted">No invoices</td></tr>
            </#if>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <script>
    (function(){
      const alertPlaceholder = document.getElementById('alertPlaceholder');
      function showAlert(message, type){
        alertPlaceholder.innerHTML = '<div class="alert alert-' + type + ' alert-dismissible fade show" role="alert">' + message + '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button></div>';
      }

      const invoiceForm = document.getElementById('invoiceForm');
      invoiceForm && invoiceForm.addEventListener('submit', async function(e){
        e.preventDefault();
        const patientId = Number(document.getElementById('invPatientId').value);
        const amount = parseFloat(document.getElementById('invAmount').value);
        const description = document.getElementById('invDescription').value.trim();
        if(!patientId || !amount){ showAlert('Patient and amount are required','warning'); return; }
        const payload = { patient: { id: patientId }, amount: amount, description: description };
        try{
          const res = await fetch('/api/invoices', { method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify(payload) });
          if(res.ok){ showAlert('Invoice created','success'); setTimeout(()=> location.reload(),700); }
          else { const txt = await res.text(); showAlert('Error: '+txt,'danger'); }
        }catch(err){ showAlert('Unexpected: '+err.message, 'danger'); }
      });

      // Mark as paid buttons
      document.querySelectorAll('.inv-pay-btn').forEach(btn => btn.addEventListener('click', async function(e){
        const id = this.dataset.id;
        if(!confirm('Mark invoice as paid?')) return;
        try{
          const res = await fetch('/api/invoices/'+id+'/paid', { method: 'PUT' });
          if(res.ok){ showAlert('Invoice marked as paid','success'); setTimeout(()=> location.reload(),500); }
          else { const txt = await res.text(); showAlert('Error: '+txt,'danger'); }
        }catch(err){ showAlert('Unexpected error: '+err.message,'danger'); }
      }));
    })();
  </script>

  <#include "../common/footer.ftlh">
</body>
</html>
