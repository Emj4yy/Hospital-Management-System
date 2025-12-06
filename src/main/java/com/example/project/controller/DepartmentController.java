package com.example.project.controller;

import com.example.project.model.Department;
import com.example.project.service.DepartmentService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/departments")
public class DepartmentController {
    private final DepartmentService service;
    public DepartmentController(DepartmentService service){ this.service = service; }

    @GetMapping
    public String list(Model model){
        model.addAttribute("departments", service.findAll());
        model.addAttribute("active", "departments");
        return "freemarker/departments/list";
    }

    @PostMapping
    public String create(@ModelAttribute Department d, RedirectAttributes ra){
        service.save(d);
        ra.addFlashAttribute("success", "Department saved");
        return "redirect:/departments";
    }

    @PostMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes ra){
        service.delete(id);
        ra.addFlashAttribute("success", "Department deleted");
        return "redirect:/departments";
    }
}

