using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using ph_project01.Data;
using ph_project01.Models;

namespace ph_project01.Controllers
{
    public class Module01Controller : Controller
    {
        private readonly DataBaseContext _context;

        public Module01Controller(DataBaseContext context)
        {
            _context = context;
        }

        // GET: Module01
        public async Task<IActionResult> Index()
        {
            return View(await _context.Module01.ToListAsync());
        }

        // GET: Module01/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var module01 = await _context.Module01
                .FirstOrDefaultAsync(m => m.ID == id);
            if (module01 == null)
            {
                return NotFound();
            }

            return View(module01);
        }

        // GET: Module01/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: Module01/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("ID,Description,CreatedDate")] Module01 module01)
        {
            if (ModelState.IsValid)
            {
                _context.Add(module01);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            return View(module01);
        }

        // GET: Module01/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var module01 = await _context.Module01.FindAsync(id);
            if (module01 == null)
            {
                return NotFound();
            }
            return View(module01);
        }

        // POST: Module01/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("ID,Description,CreatedDate")] Module01 module01)
        {
            if (id != module01.ID)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(module01);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!Module01Exists(module01.ID))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                return RedirectToAction(nameof(Index));
            }
            return View(module01);
        }

        // GET: Module01/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var module01 = await _context.Module01
                .FirstOrDefaultAsync(m => m.ID == id);
            if (module01 == null)
            {
                return NotFound();
            }

            return View(module01);
        }

        // POST: Module01/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var module01 = await _context.Module01.FindAsync(id);
            _context.Module01.Remove(module01);
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool Module01Exists(int id)
        {
            return _context.Module01.Any(e => e.ID == id);
        }
    }
}
