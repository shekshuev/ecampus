<template>
    <div class="calendar-outer">
        <div class="calendar-inner">
            <v-calendar
                v-model="value"
                color="secondary"
                :weekdays="[1, 2, 3, 4, 5, 6, 0]"
                :types="['month', 'week', 'day']"
                :events="events"
                :text="$t('components.widgets.schedule.today')"
            >
                <template #event="{ event }">
                    <div style="max-width: 118px" class="d-flex align-center justify-center px-2">
                        <v-chip color="primary" class="mb-1 cursor-pointer" @click="onClassClicked(event.id as number)">
                            <span class="text-truncate">{{ event.title }}</span>
                            <v-tooltip activator="parent" location="top">
                                <div class="d-flex flex-column align-start justify-start">
                                    <strong>{{ event.title }}</strong>
                                    <span>{{ event.classroom }}</span>
                                    <span>
                                        {{ $dayjs(event.start as Date).format("DD.MM.YYYY, HH:mm") }} -
                                        {{ $dayjs(event.end as Date).format("HH:mm") }}
                                    </span>
                                </div>
                            </v-tooltip>
                        </v-chip>
                    </div>
                </template>
            </v-calendar>
        </div>
    </div>
</template>
<script setup lang="ts">
import { VCalendar } from "vuetify/labs/VCalendar";

const props = defineProps<{
    loading: boolean;
    data: Shared.ListData<Classes.ReadClassDTO> | null;
}>();

const emit = defineEmits<{
    (e: "class-selected", cls: Classes.ReadClassDTO): void;
}>();

const value = ref([new Date()]);

const events = computed(() => {
    if (props.data) {
        return props.data.list.map((c: Classes.ReadClassDTO) => {
            return {
                title: c.lesson.title,
                classroom: c.classroom,
                start: new Date(Date.parse(c.begin_date)),
                end: new Date(Date.parse(c.begin_date) + 45 * c.lesson.hours_count * 60 * 1000),
                id: c.id
            };
        });
    } else {
        return [];
    }
});

function onClassClicked(id: number) {
    const cls = props?.data?.list?.find?.(c => c.id == id);
    if (cls) {
        emit("class-selected", cls);
    }
}
</script>
<style scoped>
::v-deep .v-chip__content {
    display: inline-block !important;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.calendar-outer {
    max-width: 100%;
    overflow-x: scroll;
}

.calendar-inner {
    min-width: max-content;
    width: 100%;
}

.v-calendar {
    min-width: 860px;
}
</style>
