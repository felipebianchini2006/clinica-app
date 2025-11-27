module ApplicationHelper
  def nav_link_class(active)
    base_classes = "inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium"
    if active
      "#{base_classes} border-indigo-500 text-gray-900"
    else
      "#{base_classes} border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700"
    end
  end

  def status_badge(status, type = :appointment)
    colors = case type
    when :appointment
      {
        "scheduled" => "bg-blue-100 text-blue-800",
        "confirmed" => "bg-green-100 text-green-800",
        "in_progress" => "bg-yellow-100 text-yellow-800",
        "completed" => "bg-gray-100 text-gray-800",
        "cancelled" => "bg-red-100 text-red-800",
        "no_show" => "bg-purple-100 text-purple-800"
      }
    when :invoice
      {
        "pending" => "bg-yellow-100 text-yellow-800",
        "paid" => "bg-green-100 text-green-800",
        "overdue" => "bg-red-100 text-red-800",
        "cancelled" => "bg-gray-100 text-gray-800"
      }
    end

    content_tag :span, status.humanize,
      class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{colors[status]}"
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
