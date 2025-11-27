import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    eventsUrl: String,
    newAppointmentUrl: String
  }

  connect() {
    this.initCalendar()
  }

  async initCalendar() {
    // Load FullCalendar from CDN (global bundle includes all plugins)
    if (!window.FullCalendar) {
      await this.loadFullCalendar()
    }

    const calendarEl = this.element

    this.calendar = new FullCalendar.Calendar(calendarEl, {
      initialView: 'timeGridWeek',
      locale: 'pt-br',
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,timeGridWeek,timeGridDay'
      },
      slotMinTime: '07:00:00',
      slotMaxTime: '20:00:00',
      slotDuration: '00:30:00',
      allDaySlot: false,
      weekends: true,
      navLinks: true,
      selectable: true,
      selectMirror: true,
      editable: false,
      dayMaxEvents: true,
      events: this.eventsUrlValue,
      eventClick: this.handleEventClick.bind(this),
      select: this.handleSelect.bind(this),
      eventDidMount: this.handleEventDidMount.bind(this),
      buttonText: {
        today: 'Hoje',
        month: 'Mês',
        week: 'Semana',
        day: 'Dia'
      },
      noEventsContent: 'Nenhuma consulta agendada'
    })

    this.calendar.render()
  }

  async loadFullCalendar() {
    return new Promise((resolve) => {
      const script = document.createElement('script')
      script.src = 'https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.js'
      script.onload = resolve
      document.head.appendChild(script)
    })
  }

  handleEventClick(info) {
    // Navigate to the appointment
    if (info.event.url) {
      info.jsEvent.preventDefault()
      window.Turbo.visit(info.event.url)
    }
  }

  handleSelect(info) {
    // Create new appointment at selected time
    const url = new URL(this.newAppointmentUrlValue, window.location.origin)
    url.searchParams.set('scheduled_at', info.startStr)
    window.Turbo.visit(url.toString())
  }

  handleEventDidMount(info) {
    // Add tooltip with appointment details
    info.el.setAttribute('title', 
      `${info.event.extendedProps.patient}\n${info.event.extendedProps.practitioner}\nStatus: ${info.event.extendedProps.status}`
    )
  }

  disconnect() {
    if (this.calendar) {
      this.calendar.destroy()
    }
  }
}
