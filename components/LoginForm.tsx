'use client'

import { zodResolver } from '@hookform/resolvers/zod'
import { useForm } from 'react-hook-form'
import * as z from 'zod'
import { useRouter } from 'next/navigation'

import { Button } from './ui/button'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import Messages from '@/app/login/messages'
import { createClient } from '@/utils/supabase/client'

const signInFormSchema = z.object({
  email: z.string().email({ message: 'Please enter a valid email' }),
  password: z.string().min(1, { message: 'Please enter your password' }),
})

export default function LoginForm() {
  const router = useRouter()
  const supabase = createClient()

  const form = useForm<z.infer<typeof signInFormSchema>>({
    resolver: zodResolver(signInFormSchema),
    defaultValues: {
      email: '',
      password: '',
    },
  })

  const signIn = async (values: z.infer<typeof signInFormSchema>) => {
    const email = values.email
    const password = values.password

    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (error) {
      router.push('/login?message=Could not authenticate user')
    } else {
      router.push('/')
    }
  }

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(signIn)}
        className="flex-1 flex flex-col w-full justify-center gap-2 text-foreground"
      >
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input placeholder="you@example.com" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="password"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Password</FormLabel>
              <FormControl>
                <Input placeholder="••••••••" type="password" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <Button type="submit" className="mb-2 mt-4">
          Sign In
        </Button>
        <Messages />
      </form>
    </Form>
  )
}
