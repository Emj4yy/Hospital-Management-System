<!DOCTYPE html>
<html>
<head>
    <title>Schedule Appointment</title>
    <!-- Styles via header; include flatpickr CSS here -->
    <link href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css" rel="stylesheet">
</head>
<body>
    <#include "../common/header.ftlh">

    <div class="container">
        <div class="d-flex align-items-center mb-3">
            <div class="page-title d-flex align-items-center gap-2"><span class="emoji">🗓️</span><h1 class="m-0">Schedule Appointment</h1></div>
            <div class="ms-auto muted small">Patient: ${patient.firstName!''} ${patient.lastName!''}</div>
        </div>

        <#if error??>
            <div class="alert alert-danger alert-dismissible fade show mt-3" role="alert">
                ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </#if>

        <div class="card form-section">
            <div class="card-body">
                <form action="/appointments/schedule/${patient.id}" method="post" id="appointmentForm">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label for="appointmentDateTime" class="form-label">Date and Time</label>
                            <input type="text" class="form-control form-control-sm" id="appointmentDateTime" name="appointmentDateTime" required placeholder="YYYY-MM-DD hh:mm AM/PM">
                            <div class="form-text">Use the picker to select date and time (AM/PM).</div>
                        </div>
                        <div class="col-md-6">
                            <label for="purpose" class="form-label">Purpose</label>
                            <input type="text" class="form-control form-control-sm" id="purpose" name="purpose" required placeholder="e.g., Consultation">
                        </div>
                        <div class="col-12">
                            <label for="notes" class="form-label">Notes (Optional)</label>
                            <textarea class="form-control form-control-sm" id="notes" name="notes" rows="3" placeholder="Optional details..."></textarea>
                        </div>
                    </div>
                    <div class="mt-3 d-flex gap-2">
                        <button type="submit" class="btn btn-primary btn-sm">Schedule</button>
                        <a href="/patients/${patient.id}" class="btn btn-secondary btn-sm">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <#include "../common/footer.ftlh">
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            flatpickr("#appointmentDateTime", {
                enableTime: true,
                // Use ISO-like value for submission to avoid AM/PM parsing issues on the server
                dateFormat: "Y-m-d\\TH:i",
                // Show a friendly AM/PM display to the user
                altInput: true,
                altFormat: "Y-m-d h:i K",
                minDate: "today",
                time_24hr: false,
                defaultHour: 9,
                minuteIncrement: 30
            });
        });

        document.getElementById('appointmentForm').addEventListener('submit', function(e) {
            const dateTime = document.getElementById('appointmentDateTime').value;
            const purpose = document.getElementById('purpose').value.trim();
            if (!dateTime) {
                e.preventDefault();
                alert('Please select a date and time');
                return;
            }
            if (!purpose) {
                e.preventDefault();
                alert('Please enter a purpose for the appointment');
                return;
            }
        });
    </script>
</body>
</html>