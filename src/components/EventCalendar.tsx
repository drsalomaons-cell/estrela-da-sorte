import React, { useEffect, useState } from "react";
import { CalendarDays, RefreshCw } from "lucide-react";
import { supabase } from "../lib/supabase";

type EventRow = {
  id: string;
  event_key: string;
  name: string;
  region_code: string;
  event_date: string;
  recurring_month: number | null;
  recurring_day: number | null;
  active: boolean;
};

export default function EventCalendar() {
  const [events, setEvents] = useState<EventRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const load = async () => {
    setLoading(true);
    setError("");
    if (!supabase) {
      setError("Supabase não configurado.");
      setLoading(false);
      return;
    }

    const { data, error: queryError } = await supabase
      .from("ecosystem_events")
      .select("id,event_key,name,region_code,event_date,recurring_month,recurring_day,active")
      .eq("active", true)
      .order("event_date", { ascending: true });

    if (queryError) setError(queryError.message);
    else setEvents((data ?? []) as EventRow[]);
    setLoading(false);
  };

  useEffect(() => {
    void load();
  }, []);

  return (
    <section className="panel">
      <div className="panelTitle">
        <span><CalendarDays size={18} /> Calendário regional</span>
        <button onClick={() => void load()} disabled={loading} aria-label="Atualizar calendário">
          <RefreshCw size={16} />
        </button>
      </div>
      {loading && <p>Consultando eventos reais…</p>}
      {error && <div className="notice"><span>{error}</span></div>}
      {!loading && !error && events.length === 0 && <p>Nenhum evento ativo cadastrado.</p>}
      {!loading && !error && events.map((event) => (
        <div className="card" key={event.id}>
          <b>{event.name}</b>
          <span>{event.region_code} • {event.event_date}</span>
          {event.recurring_month && event.recurring_day && (
            <small>Recorrente em {String(event.recurring_day).padStart(2, "0")}/{String(event.recurring_month).padStart(2, "0")}</small>
          )}
        </div>
      ))}
    </section>
  );
}
