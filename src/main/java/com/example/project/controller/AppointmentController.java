package com.example.project.controller;

import com.example.project.model.Appointment;
import com.example.project.model.Patient;
import com.example.project.service.AppointmentService;
import com.example.project.service.PatientService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;

@Controller
@RequestMapping("/appointments")
public class AppointmentController {

    private final AppointmentService appointmentService;
    private final PatientService patientService;

    @Autowired
    public AppointmentController(AppointmentService appointmentService, PatientService patientService) {
        this.appointmentService = appointmentService;
        this.patientService = patientService;
    }

    @GetMapping
    public String listAppointments(Model model) {
        try {
            List<Appointment> todayAppointments = appointmentService.getTodaysAppointments();
            List<Appointment> upcomingAppointments = appointmentService.getUpcomingAppointments();

            // Add debug information
            todayAppointments.forEach(appointment -> {
                System.out.println("Today's appointment date: " + appointment.getAppointmentDateTime());
            });

            upcomingAppointments.forEach(appointment -> {
                System.out.println("Upcoming appointment date: " + appointment.getAppointmentDateTime());
            });

            // Add patients list for quick-scheduling from the appointments page
            List<Patient> patients = patientService.getAllPatients();

            model.addAttribute("todayAppointments", todayAppointments);
            model.addAttribute("upcomingAppointments", upcomingAppointments);
            model.addAttribute("patients", patients);
            model.addAttribute("active", "appointments");

            return "freemarker/appointments/list";
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("error", "Error loading appointments: " + e.getMessage());
            return "freemarker/appointments/list";
        }
    }

    @GetMapping("/schedule/{patientId}")
    public String showScheduleForm(@PathVariable Long patientId, Model model) {
        try {
            Patient patient = patientService.getPatientById(patientId)
                    .orElseThrow(() -> new RuntimeException("Patient not found"));

            model.addAttribute("patient", patient);
            model.addAttribute("currentDateTime", LocalDateTime.now());
            model.addAttribute("active", "appointments");
            return "freemarker/appointments/schedule";
        } catch (Exception e) {
            e.printStackTrace();
            return "freemarker/error";
        }
    }

    @PostMapping("/schedule/{patientId}")
    public String scheduleAppointment(
            @PathVariable Long patientId,
            @RequestParam String appointmentDateTime,
            @RequestParam String purpose,
            @RequestParam(required = false) String notes,
            RedirectAttributes redirectAttributes) {
        try {
            appointmentDateTime = appointmentDateTime.replace("'", "");

            // Match Flatpickr format first, then fallback to ISO
            LocalDateTime parsedDateTime = parseDateTimeFlexible(appointmentDateTime);

            if (parsedDateTime.isBefore(LocalDateTime.now())) {
                redirectAttributes.addFlashAttribute("error", "Appointment date cannot be in the past");
                return "redirect:/appointments/schedule/" + patientId;
            }

            Patient patient = patientService.getPatientById(patientId)
                    .orElseThrow(() -> new RuntimeException("Patient not found"));

            Appointment appointment = new Appointment();
            appointment.setPatient(patient);
            appointment.setAppointmentDateTime(parsedDateTime);
            appointment.setPurpose(purpose);
            appointment.setNotes(notes);
            appointment.setStatus("SCHEDULED");

            appointmentService.scheduleAppointment(appointment);

            redirectAttributes.addFlashAttribute("success", "Appointment scheduled successfully");
            return "redirect:/appointments";
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Error scheduling appointment: " + e.getMessage());
            return "redirect:/appointments/schedule/" + patientId;
        }
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Long id, Model model) {
        try {
            Appointment appointment = appointmentService.getAppointmentById(id)
                    .orElseThrow(() -> new RuntimeException("Appointment not found"));

            model.addAttribute("appointment", appointment);
            model.addAttribute("currentDateTime", LocalDateTime.now());
            model.addAttribute("active", "appointments");
            return "freemarker/appointments/edit";
        } catch (Exception e) {
            e.printStackTrace();
            return "freemarker/error";
        }
    }

    @PostMapping("/edit/{id}")
    public String updateAppointment(
            @PathVariable Long id,
            @RequestParam String appointmentDateTime,
            @RequestParam String purpose,
            @RequestParam(required = false) String notes,
            RedirectAttributes redirectAttributes) {
        try {
            Appointment appointment = appointmentService.getAppointmentById(id)
                    .orElseThrow(() -> new RuntimeException("Appointment not found"));

            appointmentDateTime = appointmentDateTime.replace("'", "");
            LocalDateTime parsedDateTime = parseDateTimeFlexible(appointmentDateTime);

            if (parsedDateTime.isBefore(LocalDateTime.now())) {
                redirectAttributes.addFlashAttribute("error", "Appointment date cannot be in the past");
                return "redirect:/appointments/edit/" + id;
            }

            appointment.setAppointmentDateTime(parsedDateTime);
            appointment.setPurpose(purpose);
            appointment.setNotes(notes);

            appointmentService.updateAppointment(appointment);

            redirectAttributes.addFlashAttribute("success", "Appointment updated successfully");
            return "redirect:/appointments";
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Error updating appointment: " + e.getMessage());
            return "redirect:/appointments/edit/" + id;
        }
    }

    @GetMapping("/cancel/{id}")
    public String cancelAppointment(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        try {
            appointmentService.cancelAppointment(id);
            redirectAttributes.addFlashAttribute("success", "Appointment cancelled successfully");
            return "redirect:/appointments";
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Error cancelling appointment: " + e.getMessage());
            return "redirect:/appointments";
        }
    }

    @GetMapping("/complete/{id}")
    public String completeAppointment(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        try {
            appointmentService.completeAppointment(id);
            redirectAttributes.addFlashAttribute("success", "Appointment marked as completed");
            return "redirect:/appointments";
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Error completing appointment: " + e.getMessage());
            return "redirect:/appointments";
        }
    }

    private LocalDateTime parseDateTimeFlexible(String value) {
        // Normalize and strip quotes
        value = value == null ? "" : value.trim();
        if (value.startsWith("'") && value.endsWith("'")) {
            value = value.substring(1, value.length() - 1).trim();
        }

        // Normalize whitespace
        value = value.replaceAll("\\s+", " ");

        // If contains AM/PM, try a robust regex-based parse first
        if (value.toUpperCase().contains("AM") || value.toUpperCase().contains("PM")) {
            try {
                String normalized = value.replace('T', ' ').trim();
                java.util.regex.Pattern p = java.util.regex.Pattern.compile("(\\d{4}-\\d{2}-\\d{2})[ T]+(\\d{1,2}):(\\d{2})\\s*([AaPp][Mm])");
                java.util.regex.Matcher m = p.matcher(normalized);
                if (m.find()) {
                    String datePart = m.group(1);
                    String hourPart = m.group(2);
                    String minutePart = m.group(3);
                    String ampmPart = m.group(4).toUpperCase();

                    java.time.LocalDate date = java.time.LocalDate.parse(datePart); // ISO date
                    int hour = Integer.parseInt(hourPart);
                    int minute = Integer.parseInt(minutePart);
                    if (ampmPart.equals("PM") && hour < 12) hour += 12;
                    if (ampmPart.equals("AM") && hour == 12) hour = 0;
                    return java.time.LocalDateTime.of(date, java.time.LocalTime.of(hour, minute));
                }
            } catch (Exception ignored) {
                // Fall through to other attempts below
            }
        }

        // Common format attempts (with Locale.ENGLISH for AM/PM parsing)
        java.util.Locale en = java.util.Locale.ENGLISH;
        String[] patterns = new String[] {
            "yyyy-MM-dd'T'HH:mm",     // 24h with T
            "yyyy-MM-dd HH:mm",       // 24h with space
            "yyyy-MM-dd H:mm",        // 24h single-digit hour
            "yyyy-MM-dd h:mm a",      // 12h with AM/PM
            "yyyy-MM-dd hh:mm a",     // 12h two-digit hour with AM/PM
            "yyyy-MM-dd'T'h:mm a",    // 12h with T
            "yyyy-MM-dd'T'hh:mm a"    // 12h with T and two-digit hour
        };

        for (String pat : patterns) {
            try {
                DateTimeFormatter fmt = DateTimeFormatter.ofPattern(pat, en);
                return LocalDateTime.parse(value, fmt);
            } catch (DateTimeParseException ignored) {
            }
        }

        // Fallback: try ISO generic parse
        try {
            return LocalDateTime.parse(value);
        } catch (DateTimeParseException ignored) {
        }

        // Last resort: try with seconds
        try {
            DateTimeFormatter withSeconds = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
            return LocalDateTime.parse(value, withSeconds);
        } catch (DateTimeParseException e) {
            // rethrow as runtime so caller sees the cause (will be caught in controller)
            throw e;
        }
    }
}