module ApplicationHelper
  def nav_link_class(active)
    base_classes = "inline-flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-all duration-200"
    if active
      "#{base_classes} bg-indigo-50 text-indigo-700"
    else
      "#{base_classes} text-slate-600 hover:text-indigo-600 hover:bg-slate-50"
    end
  end

  def mobile_nav_link_class(active)
    base_classes = "block pl-4 pr-4 py-3 text-base font-medium border-l-4 transition-colors"
    if active
      "#{base_classes} bg-indigo-50 border-indigo-500 text-indigo-700"
    else
      "#{base_classes} border-transparent text-slate-600 hover:bg-slate-50 hover:border-slate-300 hover:text-slate-800"
    end
  end

  def status_badge(status, type = :appointment)
    colors = case type
    when :appointment
      {
        "scheduled" => "bg-blue-50 text-blue-700 ring-1 ring-inset ring-blue-600/20",
        "confirmed" => "bg-emerald-50 text-emerald-700 ring-1 ring-inset ring-emerald-600/20",
        "in_progress" => "bg-amber-50 text-amber-700 ring-1 ring-inset ring-amber-600/20",
        "completed" => "bg-slate-50 text-slate-700 ring-1 ring-inset ring-slate-600/20",
        "cancelled" => "bg-red-50 text-red-700 ring-1 ring-inset ring-red-600/20",
        "no_show" => "bg-purple-50 text-purple-700 ring-1 ring-inset ring-purple-600/20"
      }
    when :invoice
      {
        "pending" => "bg-amber-50 text-amber-700 ring-1 ring-inset ring-amber-600/20",
        "paid" => "bg-emerald-50 text-emerald-700 ring-1 ring-inset ring-emerald-600/20",
        "overdue" => "bg-red-50 text-red-700 ring-1 ring-inset ring-red-600/20",
        "cancelled" => "bg-slate-50 text-slate-700 ring-1 ring-inset ring-slate-600/20"
      }
    end

    content_tag :span, status.humanize,
      class: "inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-medium #{colors[status]}"
  end

  def format_currency(amount)
    number_to_currency(amount, unit: "R$ ", separator: ",", delimiter: ".")
  end

  def format_date(date)
    return "-" unless date
    l(date, format: :short)
  end

  def format_datetime(datetime)
    return "-" unless datetime
    l(datetime, format: :short)
  end
end
