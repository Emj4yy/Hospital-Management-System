package com.example.project.controller;

import com.example.project.service.PatientService;
import com.example.project.service.AdmissionService;
import com.example.project.service.PrescriptionService;
import com.example.project.service.InvoiceService;
import com.example.project.service.DoctorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import java.util.HashMap;
import java.util.Map;
import java.time.LocalDate;

@Controller
public class DashboardController {

    private final PatientService patientService;
    private final AdmissionService admissionService;
    private final PrescriptionService prescriptionService;
    private final InvoiceService invoiceService;
    private final DoctorService doctorService;

    @Autowired
    public DashboardController(PatientService patientService,
                               AdmissionService admissionService,
                               PrescriptionService prescriptionService,
                               InvoiceService invoiceService,
                               DoctorService doctorService) {
        this.patientService = patientService;
        this.admissionService = admissionService;
        this.prescriptionService = prescriptionService;
        this.invoiceService = invoiceService;
        this.doctorService = doctorService;
    }

    @GetMapping("/")
    public String home() {
        return "redirect:/dashboard";
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        try {
            model.addAttribute("totalPatients", patientService.getAllPatients().size());
            model.addAttribute("patients", patientService.getAllPatients());
            model.addAttribute("todayAppointments", patientService.getTodaysAppointments());
            model.addAttribute("upcomingAppointments", patientService.getUpcomingAppointments());
            model.addAttribute("admissions", admissionService.findAll());
            model.addAttribute("prescriptions", prescriptionService.findAll());
            model.addAttribute("invoices", invoiceService.findAll());
            model.addAttribute("totalDoctors", doctorService.findAll().size());
            // Change this to match your template path
            return "freemarker/dashboard";
        } catch (Exception e) {
            e.printStackTrace(); // Add this to see errors in console
            return "freemarker/error";
        }
    }

    @GetMapping(value = "/dashboard/stats", produces = "application/json")
    @ResponseBody
    public Map<String, Object> dashboardStats() {
        Map<String, Object> m = new HashMap<>();
        try {
            int totalPatients = patientService.getAllPatients().size();
            // compute new patients today
            java.time.LocalDateTime startOfDay = java.time.LocalDate.now().atStartOfDay();
            java.time.LocalDateTime endOfDay = startOfDay.plusDays(1);
            long newPatientsToday = 0L;
            try{
                newPatientsToday = patientService.countPatientsCreatedBetween(startOfDay, endOfDay);
            }catch(Exception ignore){ newPatientsToday = 0L; }

            int todayAppointmentsCount = patientService.getTodaysAppointments().size();

            double unpaidTotal = 0.0;
            try {
                var invoices = invoiceService.findAll();
                for (var inv : invoices) {
                    if (inv.getStatus() == null || !"PAID".equalsIgnoreCase(inv.getStatus())) {
                        try {
                            unpaidTotal += Double.parseDouble(String.valueOf(inv.getAmount()));
                        } catch (Exception ex) {
                            // ignore non-numeric
                        }
                    }
                }
            } catch (Exception ignore) {}

            m.put("totalPatients", totalPatients);
            m.put("newPatientsToday", newPatientsToday);
            m.put("todayAppointmentsCount", todayAppointmentsCount);
            m.put("unpaidTotal", String.format("%.2f", unpaidTotal));
            m.put("ok", true);
        } catch (Exception e) {
            e.printStackTrace();
            m.put("ok", false);
            m.put("error", e.getMessage());
        }
        return m;
    }
}